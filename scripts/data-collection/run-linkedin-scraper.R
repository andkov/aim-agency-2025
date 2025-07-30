#!/usr/bin/env Rscript
# LinkedIn Profile Scraping Execution Script
# Agency Summer 2025 Event Impact Monitoring
# 
# This script executes the LinkedIn profile scraping for the specified profiles
# on the event date (2025-07-29)

# Load configuration and functions
source(here::here("scripts", "data-collection", "linkedin-config.R"))
source(here::here("scripts", "data-collection", "linkedin-utils.R"))
source(here::here("scripts", "data-collection", "linkedin-profile-scraper.R"))

library(here)
library(magrittr)

# Execution function
main <- function() {
  cat("=== Agency Summer 2025 LinkedIn Impact Monitor ===\n")
  cat("Event:", EVENT_CONFIG$name, "\n")
  cat("Date:", as.character(EVENT_CONFIG$date), "\n")
  cat("Profiles to monitor:", length(TARGET_PROFILES), "\n\n")
  
  # Validate configuration
  validate_configuration()
  
  # Check ethical compliance
  check_ethical_compliance()
  
  # Execute scraping
  cat("Starting profile scraping...\n")
  results <- scrape_linkedin_profiles(
    profiles = TARGET_PROFILES,
    target_date = EVENT_CONFIG$date
  )
  
  # Generate analysis
  cat("\nGenerating analysis...\n")
  analysis_results <- analyze_scraped_data(results)
  
  # Create summary report
  cat("\nCreating summary report...\n")
  summary_report <- create_summary_report(results, analysis_results)
  
  cat("\n=== Execution Complete ===\n")
  cat("Check data-private/ directory for results\n")
  
  return(list(
    scraping_results = results,
    analysis = analysis_results,
    summary = summary_report
  ))
}

# Configuration validation
validate_configuration <- function() {
  cat("Validating configuration...\n")
  
  # Check profile URLs
  invalid_urls <- TARGET_PROFILES[!map_lgl(TARGET_PROFILES, validate_profile_url)]
  if(length(invalid_urls) > 0) {
    warning("Invalid profile URLs found: ", paste(names(invalid_urls), collapse = ", "))
  }
  
  # Check date
  if(EVENT_CONFIG$date > Sys.Date()) {
    cat("Note: Target date is in the future. Will look for recent activity.\n")
  }
  
  # Validate directories
  required_dirs <- c(
    OUTPUT_CONFIG$raw_data_dir,
    OUTPUT_CONFIG$processed_data_dir,
    OUTPUT_CONFIG$logs_dir
  )
  
  for(dir in required_dirs) {
    if(!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE, showWarnings = FALSE)
      cat("Created directory:", dir, "\n")
    }
  }
  
  cat("Configuration validation complete.\n\n")
}

# Ethical compliance check
check_ethical_compliance <- function() {
  cat("Checking ethical compliance...\n")
  
  if(ETHICS_CONFIG$respect_robots_txt) {
    robots_info <- check_robots_compliance("https://www.linkedin.com")
    if(!is.null(robots_info$error)) {
      warning("Could not check robots.txt: ", robots_info$error)
    } else {
      cat("Robots.txt checked. Found", length(robots_info$disallow_rules), "disallow rules.\n")
    }
  }
  
  # Rate limiting check
  if(SCRAPING_CONFIG$min_delay_seconds < 2) {
    warning("Minimum delay is very low. Consider increasing for politeness.")
  }
  
  # Privacy settings check
  if(!SCRAPING_CONFIG$anonymize_names) {
    warning("Name anonymization is disabled. Ensure compliance with privacy requirements.")
  }
  
  cat("Ethical compliance check complete.\n\n")
}

# Data analysis function
analyze_scraped_data <- function(results) {
  cat("Analyzing scraped data...\n")
  
  # Generate summary statistics
  summary_stats <- generate_scraping_summary(results)
  
  # Extract hashtags across all posts
  all_hashtags <- results %>%
    map("posts") %>%
    flatten() %>%
    map_chr(~.x$text %||% "") %>%
    map(extract_hashtags) %>%
    flatten_chr() %>%
    table() %>%
    sort(decreasing = TRUE)
  
  # Extract mentions
  all_mentions <- results %>%
    map("posts") %>%
    flatten() %>%
    map_chr(~.x$text %||% "") %>%
    map(extract_mentions) %>%
    flatten_chr() %>%
    table() %>%
    sort(decreasing = TRUE)
  
  # Calculate total engagement
  total_engagement <- results %>%
    map("posts") %>%
    flatten() %>%
    map(function(post) {
      eng <- post$engagement %||% list(reactions = 0, comments = 0, reposts = 0)
      calculate_engagement_score(eng$reactions, eng$comments, eng$reposts)
    }) %>%
    reduce(`+`, .init = 0)
  
  # Event-relevant posts
  relevant_posts <- results %>%
    map("posts") %>%
    flatten() %>%
    keep(~.x$is_relevant %||% FALSE)
  
  analysis <- list(
    summary_stats = summary_stats,
    hashtags = all_hashtags,
    mentions = all_mentions,
    total_engagement = total_engagement,
    relevant_posts = relevant_posts,
    analyzed_at = Sys.time()
  )
  
  # Save analysis
  analysis_file <- file.path(
    OUTPUT_CONFIG$processed_data_dir,
    paste0("analysis_", format(Sys.Date(), "%Y%m%d"), ".rds")
  )
  saveRDS(analysis, analysis_file)
  
  cat("Analysis saved to:", analysis_file, "\n")
  return(analysis)
}

# Summary report generation
create_summary_report <- function(results, analysis) {
  cat("Creating summary report...\n")
  
  report_content <- c(
    "# Agency Summer 2025 LinkedIn Impact Report",
    paste("Generated:", Sys.time()),
    "",
    "## Overview",
    paste("- Event Date:", EVENT_CONFIG$date),
    paste("- Profiles Monitored:", length(TARGET_PROFILES)),
    paste("- Successful Scrapes:", sum(map_lgl(results, ~.x$status == "success"))),
    paste("- Total Posts Collected:", sum(map_int(results, ~length(.x$posts %||% list())))),
    paste("- Event-Relevant Posts:", length(analysis$relevant_posts)),
    "",
    "## Profile Summary",
    ""
  )
  
  # Add profile-by-profile summary
  for(profile_name in names(results)) {
    profile <- results[[profile_name]]
    posts_count <- length(profile$posts %||% list())
    relevant_count <- sum(map_lgl(profile$posts %||% list(), ~.x$is_relevant %||% FALSE))
    
    report_content <- c(
      report_content,
      paste("###", profile_name),
      paste("- Status:", profile$status),
      paste("- Posts Found:", posts_count),
      paste("- Event-Relevant:", relevant_count),
      ""
    )
  }
  
  # Add hashtag summary
  if(length(analysis$hashtags) > 0) {
    report_content <- c(
      report_content,
      "## Top Hashtags",
      paste("-", names(analysis$hashtags)[1:min(10, length(analysis$hashtags))], 
            "(", analysis$hashtags[1:min(10, length(analysis$hashtags))], ")"),
      ""
    )
  }
  
  # Save report
  report_file <- file.path(
    OUTPUT_CONFIG$processed_data_dir,
    paste0("summary_report_", format(Sys.Date(), "%Y%m%d"), ".md")
  )
  writeLines(report_content, report_file)
  
  cat("Summary report saved to:", report_file, "\n")
  return(report_file)
}

# Execute if run as script
if(!interactive()) {
  # Check if RSelenium is available
  if(!requireNamespace("RSelenium", quietly = TRUE)) {
    stop("RSelenium package is required. Install with: install.packages('RSelenium')")
  }
  
  # Execute main function
  results <- main()
}
