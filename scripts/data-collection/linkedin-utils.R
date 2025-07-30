# Common functions for LinkedIn scraping
# Supporting utilities for data collection

library(stringr)
library(readr)
library(dplyr)
library(purrr)
library(tibble)

#' Check robots.txt compliance
#' 
#' @param base_url Base URL to check
#' @return List with robots.txt info and compliance status
check_robots_compliance <- function(base_url = "https://www.linkedin.com") {
  robots_url <- paste0(base_url, "/robots.txt")
  
  tryCatch({
    robots_content <- read_lines(robots_url)
    
    # Look for relevant bot restrictions
    user_agent_sections <- which(str_detect(robots_content, "^User-agent:"))
    disallow_rules <- robots_content[str_detect(robots_content, "^Disallow:")]
    crawl_delay <- robots_content[str_detect(robots_content, "^Crawl-delay:")]
    
    return(list(
      url = robots_url,
      user_agents = length(user_agent_sections),
      disallow_rules = disallow_rules,
      crawl_delay = crawl_delay,
      checked_at = Sys.time()
    ))
    
  }, error = function(e) {
    return(list(error = e$message, checked_at = Sys.time()))
  })
}

#' Validate LinkedIn profile URL format
#' 
#' @param url LinkedIn profile URL
#' @return Boolean indicating valid format
validate_profile_url <- function(url) {
  linkedin_pattern <- "^https://www\\.linkedin\\.com/in/[a-zA-Z0-9\\-]+/?$"
  return(str_detect(url, linkedin_pattern))
}

#' Clean and standardize profile URLs
#' 
#' @param urls Vector of LinkedIn profile URLs
#' @return Vector of cleaned URLs
clean_profile_urls <- function(urls) {
  urls %>%
    # Remove trailing slashes and parameters
    str_remove("\\?.*$") %>%
    str_remove("/$") %>%
    # Ensure proper format
    str_replace("^(https://)?", "https://") %>%
    str_replace("linkedin\\.com", "www.linkedin.com") %>%
    # Add trailing slash for consistency
    paste0("/")
}

#' Create session log for scraping activity
#' 
#' @param session_id Unique identifier for scraping session
#' @param profiles List of profiles being scraped
#' @return Log file path
create_session_log <- function(session_id = NULL, profiles) {
  if(is.null(session_id)) {
    session_id <- paste0("linkedin_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }
  
  log_dir <- file.path("data-private", "logs")
  dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  
  log_file <- file.path(log_dir, paste0(session_id, ".log"))
  
  # Write session header
  log_content <- c(
    paste("=== LinkedIn Scraping Session ==="),
    paste("Session ID:", session_id),
    paste("Start Time:", Sys.time()),
    paste("Profiles:", length(profiles)),
    paste("Target Profiles:"),
    paste(" -", names(profiles), ":", profiles),
    ""
  )
  
  writeLines(log_content, log_file)
  
  return(log_file)
}

#' Log scraping activity
#' 
#' @param log_file Path to log file
#' @param message Log message
#' @param level Log level (INFO, WARN, ERROR)
log_activity <- function(log_file, message, level = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- paste0("[", timestamp, "] [", level, "] ", message)
  
  # Append to log file
  cat(log_entry, "\n", file = log_file, append = TRUE)
  
  # Also print to console
  cat(log_entry, "\n")
}

#' Detect if page requires authentication
#' 
#' @param page_source HTML source of page
#' @return Boolean indicating auth requirement
detect_auth_wall <- function(page_source) {
  auth_indicators <- c(
    "authwall",
    "sign in",
    "join now", 
    "member login",
    "authentication required",
    "please sign in"
  )
  
  return(any(str_detect(str_to_lower(page_source), auth_indicators)))
}

#' Extract post hashtags
#' 
#' @param text Post text content
#' @return Vector of hashtags
extract_hashtags <- function(text) {
  hashtags <- str_extract_all(text, "#\\w+")[[1]]
  return(unique(str_to_lower(hashtags)))
}

#' Extract mentions from post
#' 
#' @param text Post text content  
#' @return Vector of mentions (without @)
extract_mentions <- function(text) {
  mentions <- str_extract_all(text, "@\\w+")[[1]]
  mentions <- str_remove(mentions, "@")
  return(unique(str_to_lower(mentions)))
}

#' Calculate engagement score
#' 
#' @param reactions Number of reactions/likes
#' @param comments Number of comments
#' @param reposts Number of reposts/shares
#' @return Numeric engagement score
calculate_engagement_score <- function(reactions = 0, comments = 0, reposts = 0) {
  # Weight different engagement types
  # Comments are more valuable than likes, reposts most valuable
  score <- (reactions * 1) + (comments * 3) + (reposts * 5)
  return(score)
}

#' Parse LinkedIn relative dates
#' 
#' @param date_text Relative date text from LinkedIn
#' @param reference_date Reference date for calculation
#' @return Estimated actual date
parse_linkedin_date <- function(date_text, reference_date = Sys.Date()) {
  if(is.na(date_text) || nchar(date_text) == 0) {
    return(NA)
  }
  
  date_text <- str_to_lower(str_trim(date_text))
  
  # Handle various LinkedIn date formats
  if(str_detect(date_text, "now|just now")) {
    return(reference_date)
  } else if(str_detect(date_text, "(\\d+)\\s*h")) {
    hours <- as.numeric(str_extract(date_text, "\\d+"))
    return(reference_date - hours/24)
  } else if(str_detect(date_text, "(\\d+)\\s*d")) {
    days <- as.numeric(str_extract(date_text, "\\d+"))
    return(reference_date - days)
  } else if(str_detect(date_text, "(\\d+)\\s*w")) {
    weeks <- as.numeric(str_extract(date_text, "\\d+"))
    return(reference_date - weeks * 7)
  } else if(str_detect(date_text, "(\\d+)\\s*m")) {
    months <- as.numeric(str_extract(date_text, "\\d+"))
    return(reference_date - months * 30)
  } else {
    # Try to parse absolute dates
    tryCatch({
      return(as.Date(date_text))
    }, error = function(e) {
      return(NA)
    })
  }
}

#' Generate summary statistics for scraped data
#' 
#' @param results List of profile scraping results
#' @return Summary data frame
generate_scraping_summary <- function(results) {
  summary_data <- map_dfr(results, function(profile) {
    posts <- profile$posts %||% list()
    
    tibble(
      profile_id = profile$profile %||% "unknown",
      status = profile$status %||% "unknown",
      total_posts = length(posts),
      relevant_posts = sum(map_lgl(posts, ~.x$is_relevant %||% FALSE)),
      total_engagement = sum(map_dbl(posts, function(p) {
        eng <- p$engagement %||% list(reactions = 0, comments = 0, reposts = 0)
        calculate_engagement_score(eng$reactions, eng$comments, eng$reposts)
      })),
      hashtags_found = posts %>%
        map(~extract_hashtags(.x$text %||% "")) %>%
        flatten_chr() %>%
        unique() %>%
        length(),
      scraped_at = profile$scraped_at %||% Sys.time()
    )
  })
  
  return(summary_data)
}
