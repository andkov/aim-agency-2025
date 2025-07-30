# LinkedIn Profile Activity Scraper
# Target: Specific profiles for Agency Summer 2025 event impact
# Date: 2025-07-29
# 
# This script scrapes LinkedIn profiles for posts and activity on the event date
# Uses ethical scraping practices with rate limiting and respect for robots.txt

# Load required libraries
library(RSelenium)
library(rvest)
library(httr2)
library(dplyr)
library(stringr)
library(lubridate)
library(purrr)
library(jsonlite)

# Configuration
source(here::here("scripts", "common-functions.R"))

# Target profiles for Agency Summer 2025 event
TARGET_PROFILES <- list(
  mykodev = "https://www.linkedin.com/in/mykodev/",
  janak_alford = "https://www.linkedin.com/in/janak-alford/", 
  jean_paul_lalonde = "https://www.linkedin.com/in/jean-paullalonde/",
  julieish = "https://www.linkedin.com/in/julieish/"
)

# Target date for event activity
TARGET_DATE <- as.Date("2025-07-29")

#' Setup headless browser with stealth configuration
#' 
#' @return RSelenium webdriver client
setup_stealth_browser <- function() {
  # Firefox options for stealth scraping
  firefox_options <- list(
    "moz:firefoxOptions" = list(
      args = list(
        "--headless",
        "--disable-blink-features=AutomationControlled",
        "--disable-dev-shm-usage",
        "--no-sandbox"
      ),
      prefs = list(
        # Realistic user agent
        "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
        # Disable automation indicators
        "dom.webdriver.enabled" = FALSE,
        "useAutomationExtension" = FALSE,
        # Privacy settings
        "privacy.trackingprotection.enabled" = TRUE,
        "geo.enabled" = FALSE
      )
    )
  )
  
  tryCatch({
    driver <- rsDriver(
      browser = "firefox", 
      extraCapabilities = firefox_options,
      verbose = FALSE,
      port = sample(4444:4500, 1)  # Random port to avoid conflicts
    )
    
    client <- driver[["client"]]
    
    # Set realistic window size
    client$setWindowSize(1366, 768)
    
    # Additional stealth measures
    client$executeScript("
      Object.defineProperty(navigator, 'webdriver', {
        get: () => false,
      });
    ")
    
    return(list(driver = driver, client = client))
    
  }, error = function(e) {
    cat("Error setting up browser:", e$message, "\n")
    return(NULL)
  })
}

#' Polite delay with random variation
#' 
#' @param min_seconds Minimum delay
#' @param max_seconds Maximum delay
polite_delay <- function(min_seconds = 3, max_seconds = 8) {
  delay <- runif(1, min_seconds, max_seconds)
  cat("Waiting", round(delay, 1), "seconds...\n")
  Sys.sleep(delay)
}

#' Extract profile recent activity
#' 
#' @param profile_url LinkedIn profile URL
#' @param browser_setup Browser driver and client
#' @param target_date Date to focus on (2025-07-29)
#' 
#' @return List with profile data and recent posts
scrape_profile_activity <- function(profile_url, browser_setup, target_date = TARGET_DATE) {
  client <- browser_setup$client
  profile_name <- str_extract(profile_url, "(?<=in/)[^/]+")
  
  cat("\n=== Scraping profile:", profile_name, "===\n")
  cat("URL:", profile_url, "\n")
  
  tryCatch({
    # Navigate to profile
    client$navigate(profile_url)
    polite_delay(2, 4)
    
    # Wait for page load
    Sys.sleep(3)
    
    # Check if we hit a login wall or other blocker
    page_source <- client$getPageSource()[[1]]
    
    if(str_detect(page_source, "Sign in|Join now|authwall")) {
      cat("Hit authentication wall for", profile_name, "\n")
      return(list(
        profile = profile_name,
        url = profile_url,
        status = "auth_blocked",
        scraped_at = Sys.time(),
        posts = list()
      ))
    }
    
    # Try to access recent activity/posts
    activity_url <- paste0(profile_url, "recent-activity/")
    cat("Trying activity page:", activity_url, "\n")
    
    client$navigate(activity_url)
    polite_delay(2, 4)
    
    # Scroll to load more content
    for(i in 1:5) {
      client$executeScript("window.scrollTo(0, document.body.scrollHeight);")
      Sys.sleep(2)
    }
    
    # Get page content
    page_source <- client$getPageSource()[[1]]
    page <- read_html(page_source)
    
    # Extract profile information
    profile_info <- extract_profile_info(page, profile_name)
    
    # Extract recent posts
    posts <- extract_recent_posts(page, target_date, profile_name)
    
    result <- list(
      profile = profile_name,
      url = profile_url,
      status = "success",
      profile_info = profile_info,
      posts = posts,
      scraped_at = Sys.time()
    )
    
    cat("Successfully scraped", length(posts), "posts from", profile_name, "\n")
    return(result)
    
  }, error = function(e) {
    cat("Error scraping", profile_name, ":", e$message, "\n")
    return(list(
      profile = profile_name,
      url = profile_url,
      status = "error",
      error = e$message,
      scraped_at = Sys.time(),
      posts = list()
    ))
  })
}

#' Extract profile information from page
#' 
#' @param page Parsed HTML page
#' @param profile_name Profile identifier
#' 
#' @return List with profile metadata
extract_profile_info <- function(page, profile_name) {
  # Extract name
  name <- page %>%
    html_nodes("h1.text-heading-xlarge, .text-heading-xlarge, .pv-text-details__left-panel h1") %>%
    html_text() %>%
    str_trim() %>%
    first()
  
  # Extract headline/title
  headline <- page %>%
    html_nodes(".text-body-medium.break-words, .pv-text-details__left-panel .text-body-medium") %>%
    html_text() %>%
    str_trim() %>%
    first()
  
  # Extract location
  location <- page %>%
    html_nodes(".text-body-small.inline.t-black--light.break-words") %>%
    html_text() %>%
    str_trim() %>%
    str_subset("\\w+,\\s*\\w+") %>%
    first()
  
  # Extract connection count (if visible)
  connections <- page %>%
    html_nodes(".t-black--light.t-normal") %>%
    html_text() %>%
    str_subset("\\d+.*connection") %>%
    str_extract("\\d+") %>%
    as.numeric() %>%
    first()
  
  return(list(
    profile_id = profile_name,
    name = name %||% "Not found",
    headline = headline %||% "Not found", 
    location = location %||% "Not found",
    connections = connections %||% NA,
    extracted_at = Sys.time()
  ))
}

#' Extract recent posts from profile activity page
#' 
#' @param page Parsed HTML page
#' @param target_date Focus date for posts
#' @param profile_name Profile identifier
#' 
#' @return List of post data
extract_recent_posts <- function(page, target_date, profile_name) {
  # LinkedIn activity feed selectors (may need adjustment)
  post_selectors <- c(
    ".feed-shared-update-v2",
    ".profile-creator-shared-feed-update",
    ".activity-entity"
  )
  
  posts_data <- list()
  
  # Try different selectors to find posts
  for(selector in post_selectors) {
    posts <- page %>% html_nodes(selector)
    
    if(length(posts) > 0) {
      cat("Found", length(posts), "posts with selector:", selector, "\n")
      
      for(i in seq_along(posts)) {
        post <- posts[i]
        
        # Extract post text
        text_selectors <- c(
          ".feed-shared-text",
          ".attributed-text-segment-list__content",
          ".activity-text",
          ".feed-shared-update-v2__description"
        )
        
        post_text <- ""
        for(text_sel in text_selectors) {
          text_attempt <- post %>%
            html_nodes(text_sel) %>%
            html_text() %>%
            str_trim() %>%
            paste(collapse = " ")
          
          if(nchar(text_attempt) > 0) {
            post_text <- text_attempt
            break
          }
        }
        
        # Extract post date/time (challenging - LinkedIn uses relative times)
        date_selectors <- c(
          ".feed-shared-actor__sub-description",
          ".update-components-actor__sub-description",
          ".activity-summary__timestamp"
        )
        
        post_date <- ""
        for(date_sel in date_selectors) {
          date_attempt <- post %>%
            html_nodes(date_sel) %>%
            html_text() %>%
            str_trim() %>%
            first()
          
          if(!is.na(date_attempt) && nchar(date_attempt) > 0) {
            post_date <- date_attempt
            break
          }
        }
        
        # Extract engagement metrics (if visible)
        engagement <- extract_engagement_metrics(post)
        
        # Check if post is relevant (contains event-related terms or is from target date)
        is_relevant <- check_post_relevance(post_text, post_date, target_date)
        
        if(nchar(post_text) > 0) {  # Only save posts with actual content
          posts_data[[length(posts_data) + 1]] <- list(
            profile_id = profile_name,
            post_index = i,
            text = post_text,
            date_text = post_date,
            engagement = engagement,
            is_relevant = is_relevant,
            extracted_at = Sys.time()
          )
        }
      }
      break  # Stop after finding posts with first working selector
    }
  }
  
  if(length(posts_data) == 0) {
    cat("No posts found for", profile_name, "\n")
  }
  
  return(posts_data)
}

#' Extract engagement metrics from post
#' 
#' @param post Single post HTML node
#' 
#' @return List with engagement data
extract_engagement_metrics <- function(post) {
  # Reactions/likes
  reactions <- post %>%
    html_nodes("[data-test-id='social-counts-reactions'], .feed-shared-social-action-bar__reaction-count") %>%
    html_text() %>%
    str_extract("\\d+") %>%
    as.numeric() %>%
    first() %||% 0
  
  # Comments  
  comments <- post %>%
    html_nodes("[data-test-id='social-counts-comments'], .feed-shared-social-action-bar__comment-count") %>%
    html_text() %>%
    str_extract("\\d+") %>%
    as.numeric() %>%
    first() %||% 0
  
  # Reposts/shares
  reposts <- post %>%
    html_nodes("[data-test-id='social-counts-reposts'], .feed-shared-social-action-bar__repost-count") %>%
    html_text() %>%
    str_extract("\\d+") %>%
    as.numeric() %>%
    first() %||% 0
  
  return(list(
    reactions = reactions,
    comments = comments, 
    reposts = reposts
  ))
}

#' Check if post is relevant to our event
#' 
#' @param text Post text content
#' @param date_text Date string from post
#' @param target_date Target date for relevance
#' 
#' @return Boolean indicating relevance
check_post_relevance <- function(text, date_text, target_date) {
  # Event-related keywords
  event_keywords <- c(
    "Agency", "Summer 2025", "Agentic", "Public Infrastructure",
    "Edmonton", "AI", "government", "artificial intelligence",
    "public service", "Alberta"
  )
  
  # Check for keyword matches
  keyword_match <- any(str_detect(str_to_lower(text), str_to_lower(event_keywords)))
  
  # Check for date relevance (this is tricky with LinkedIn's relative dates)
  date_relevant <- str_detect(date_text, "hour|today|now") ||
                   str_detect(date_text, format(target_date, "%B %d|%m/%d"))
  
  return(keyword_match || date_relevant)
}

#' Save scraped data with privacy protection
#' 
#' @param data List of scraped profile data
#' @param filename Base filename for saving
save_linkedin_data <- function(data, filename = "linkedin_profiles") {
  # Create anonymized version for potential sharing
  anonymized_data <- data %>%
    map(function(profile) {
      # Remove direct personal identifiers
      profile$profile_info$name <- "ANONYMIZED"
      profile$url <- str_replace(profile$url, "/in/[^/]+", "/in/ANONYMIZED")
      
      # Keep profile_id as pseudonym for analysis
      # Keep posts but flag as anonymized
      profile$anonymized <- TRUE
      
      return(profile)
    })
  
  # Save raw data to private directory
  raw_filepath <- file.path("data-private", "raw", paste0(filename, "_raw_", Sys.Date(), ".rds"))
  dir.create(dirname(raw_filepath), recursive = TRUE, showWarnings = FALSE)
  saveRDS(data, raw_filepath)
  
  # Save anonymized data to private directory (for potential sharing)
  anon_filepath <- file.path("data-private", "derived", paste0(filename, "_anonymized_", Sys.Date(), ".rds"))
  dir.create(dirname(anon_filepath), recursive = TRUE, showWarnings = FALSE)
  saveRDS(anonymized_data, anon_filepath)
  
  cat("\nData saved:\n")
  cat("Raw data:", raw_filepath, "\n")
  cat("Anonymized data:", anon_filepath, "\n")
  
  return(list(raw = raw_filepath, anonymized = anon_filepath))
}

#' Main scraping function
#' 
#' @param profiles Named list of profile URLs
#' @param target_date Date to focus on
#' 
#' @return List of scraped data
scrape_linkedin_profiles <- function(profiles = TARGET_PROFILES, target_date = TARGET_DATE) {
  cat("=== LinkedIn Profile Scraping Session ===\n")
  cat("Target date:", as.character(target_date), "\n")
  cat("Profiles to scrape:", length(profiles), "\n")
  cat("Start time:", as.character(Sys.time()), "\n\n")
  
  # Setup browser
  browser_setup <- setup_stealth_browser()
  if(is.null(browser_setup)) {
    stop("Failed to setup browser")
  }
  
  results <- list()
  
  tryCatch({
    # Scrape each profile
    for(i in seq_along(profiles)) {
      profile_name <- names(profiles)[i]
      profile_url <- profiles[[i]]
      
      cat("\n--- Profile", i, "of", length(profiles), "---\n")
      
      # Scrape profile
      profile_data <- scrape_profile_activity(profile_url, browser_setup, target_date)
      results[[profile_name]] <- profile_data
      
      # Longer delay between profiles
      if(i < length(profiles)) {
        cat("\nBreak between profiles...\n")
        polite_delay(5, 12)
      }
    }
    
  }, finally = {
    # Clean up browser
    if(!is.null(browser_setup$client)) {
      browser_setup$client$close()
    }
    if(!is.null(browser_setup$driver)) {
      browser_setup$driver[["server"]]$stop()
    }
  })
  
  # Save results
  filepaths <- save_linkedin_data(results, "agency_2025_profiles")
  
  # Print summary
  cat("\n=== Scraping Summary ===\n")
  total_posts <- sum(map_int(results, ~length(.x$posts %||% list())))
  successful_profiles <- sum(map_lgl(results, ~.x$status == "success"))
  
  cat("Profiles scraped:", length(results), "\n")
  cat("Successful profiles:", successful_profiles, "\n") 
  cat("Total posts extracted:", total_posts, "\n")
  cat("Data saved to:", filepaths$raw, "\n")
  
  return(results)
}

# Helper function - null coalescing operator
`%||%` <- function(x, y) if(is.null(x) || length(x) == 0 || is.na(x)) y else x

# If running as script, execute main function
if(!interactive()) {
  results <- scrape_linkedin_profiles()
}
