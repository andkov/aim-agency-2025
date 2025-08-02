# Research Framework for AI Governance Essays
# Agency Summer 2025 Event Analysis
# 
# This script provides a framework for systematic research and investigation
# of themes emerging from the Agency Summer 2025 conference

# Load required libraries
library(tidyverse)
library(here)

# Configuration
config <- config::get()

# Source common functions
source(here("scripts", "common-functions.R"))

# ---- Research Framework Functions ----

#' Validate research source
#' 
#' @param source_info List containing source metadata
#' @return Boolean indicating if source meets ethical standards
validate_research_source <- function(source_info) {
  required_fields <- c("title", "author", "date", "type", "access_status")
  
  # Check required fields
  if (!all(required_fields %in% names(source_info))) {
    warning("Missing required source fields")
    return(FALSE)
  }
  
  # Check access permissions
  if (source_info$access_status == "private" && is.null(source_info$permission)) {
    warning("Private source requires explicit permission")
    return(FALSE)
  }
  
  return(TRUE)
}

#' Create citation entry
#' 
#' @param source_info List containing source metadata
#' @return Formatted APA citation string
create_citation <- function(source_info) {
  
  # Validate source first
  if (!validate_research_source(source_info)) {
    stop("Source validation failed")
  }
  
  # Generate citation based on type
  citation <- switch(source_info$type,
    "conference_presentation" = paste0(
      source_info$author, " (", source_info$date, "). ",
      source_info$title, " [Conference presentation]. ",
      "Agency Summer 2025: Agentic Public Infrastructure, Edmonton, AB."
    ),
    "interview" = paste0(
      source_info$author, " (", source_info$date, "). ",
      source_info$title, " [Personal interview]."
    ),
    "document" = paste0(
      source_info$author, " (", source_info$date, "). ",
      source_info$title, ". ", source_info$publication, "."
    ),
    "Unknown source type"
  )
  
  return(citation)
}

#' Track research progress
#' 
#' @param research_log Tibble containing research progress
#' @param new_entry List with new research entry
#' @return Updated research log
update_research_log <- function(research_log, new_entry) {
  
  # Add timestamp and validation
  new_entry$logged_at <- Sys.time()
  new_entry$validated <- validate_research_source(new_entry)
  
  # Add to log
  updated_log <- bind_rows(research_log, as_tibble(new_entry))
  
  # Save updated log
  save_path <- here("data-private", "research-log.rds")
  if (!dir.exists(dirname(save_path))) {
    dir.create(dirname(save_path), recursive = TRUE)
  }
  saveRDS(updated_log, save_path)
  
  message("Research log updated with new entry: ", new_entry$title)
  return(updated_log)
}

#' Generate research summary
#' 
#' @param research_log Tibble containing research entries
#' @return Summary statistics and validation report
generate_research_summary <- function(research_log) {
  
  summary_stats <- list(
    total_sources = nrow(research_log),
    source_types = table(research_log$type),
    validation_rate = mean(research_log$validated, na.rm = TRUE),
    date_range = range(research_log$date, na.rm = TRUE),
    private_sources = sum(research_log$access_status == "private", na.rm = TRUE)
  )
  
  message("Research Summary:")
  message("Total sources: ", summary_stats$total_sources)
  message("Validation rate: ", round(summary_stats$validation_rate * 100, 1), "%")
  message("Private sources requiring permission: ", summary_stats$private_sources)
  
  return(summary_stats)
}

# ---- Example Usage ----

# Initialize research log
research_log <- tibble(
  title = character(),
  author = character(),
  date = as.Date(character()),
  type = character(),
  access_status = character(),
  permission = character(),
  logged_at = as.POSIXct(character()),
  validated = logical()
)

# Example source entry
example_source <- list(
  title = "Agentic AI in Public Service: Opportunities and Challenges",
  author = "Dr. Example Speaker",
  date = as.Date("2025-07-29"),
  type = "conference_presentation",
  access_status = "public",
  permission = NA,
  notes = "Keynote presentation on AI governance frameworks"
)

# Demonstrate framework
if (interactive()) {
  # Add example source
  research_log <- update_research_log(research_log, example_source)
  
  # Generate citation
  example_citation <- create_citation(example_source)
  cat("Example citation:\n", example_citation, "\n")
  
  # Show summary
  generate_research_summary(research_log)
}

message("Research framework loaded successfully")
message("Use validate_research_source(), create_citation(), and update_research_log()")