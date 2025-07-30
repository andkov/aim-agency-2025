# ============================================================================
# COMMON FUNCTIONS - Pedagogical Foundation
# ============================================================================
# 
# Purpose: Core utility functions loaded by EVERY script in the project
# Learning Objective: Demonstrate consistent coding patterns and reusable functions
# Related Documentation: docs/architecture.md, docs/human-ai-patterns.md
#
# This file exemplifies:
# - Consistent visual styling across all project outputs
# - Utility functions that reduce code duplication  
# - Clear function naming and documentation patterns
# ============================================================================

# Base styling configuration for consistent visual output
baseSize <- 10  # Standard text size for all visualizations

# Utility function for complete data printing (helpful for debugging)
# Learning: Always know what your data looks like during development
print_all <- function(d){ 
  print(d, n = nrow(d))  # Print all rows, not just head()
}

# Negation operator for more readable conditional logic
# Learning: Custom operators can make code more expressive
`%not in%` <- Negate(`%in%`)

# ============================================================================
# CONSISTENT VISUALIZATION THEME
# ============================================================================
# 
# Decision Context: ai/project-memory.md#consistent-visualization
# Pedagogical Value: Shows how to establish visual consistency across a project
# 
# This theme will be used for all sentiment analysis visualizations,
# longitudinal tracking charts, and dashboard components to ensure
# professional, consistent output regardless of which script generates the plot.

library(ggplot2)
ggplot2::theme_set(
  ggplot2::theme_bw() +
    theme(
      strip.background = element_rect(fill = "grey95", color = NA),
      panel.grid = element_line(color = "grey95"),
      panel.border = element_rect(color = "grey80"),
      axis.ticks = element_blank(),
      text = element_text(size = baseSize)
    )
)
# ============================================================================
# AUTOMATED VISUALIZATION EXPORT
# ============================================================================
# 
# Function: quick_save()
# Purpose: Standardized plot saving with consistent quality settings
# Learning Objective: Automation reduces errors and ensures consistency
#
# Usage Example:
#   g <- ggplot(sentiment_data, aes(x=date, y=sentiment_score)) + geom_line()
#   quick_save(g, "daily_sentiment_trend")
# 
# This function will be used extensively in Phase 3 (Reporting & Visualization)
# to generate all automated report graphics with consistent formatting.

quick_save <- function(g, name, ...){
  ggplot2::ggsave(
    filename = paste0(name, ".jpg"),
    plot     = g,
    device   = "jpg",
    path     = prints_folder,  # Set by each script's environment
    dpi      = 'retina',       # High-quality output for professional reports
    limitsize = FALSE,
    ...
  )
}

# ============================================================================
# ENHANCED TABLE FORMATTING FOR REPORTS
# ============================================================================
# 
# Function: neat()
# Purpose: Professional table formatting for multiple output types
# Learning Objective: Consistent presentation across different report formats
#
# This function supports both HTML (for dashboards) and Pandoc (for PDF reports)
# enabling the same data to be presented professionally in multiple contexts.

neat <- function(x, output_format = "html"){
  if(output_format == "pandoc"){
    x_t <- knitr::kable(x, format = "pandoc")
  } else {
    x_t <- x %>%
      knitr::kable(format = output_format) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed", "responsive"),
        full_width = FALSE,
        position = "left"
      )
  }
  return(x_t)
}

# ============================================================================
# INTERACTIVE DATA EXPLORATION
# ============================================================================
# 
# Function: neat_DT() (alias: dt())
# Purpose: Interactive data tables for exploratory analysis
# Learning Objective: Enable quick data exploration during development
#
# Usage in sentiment analysis workflow:
#   social_media_posts %>% 
#     filter(sentiment_score > 0.5) %>% 
#     neat_DT(filter_="top", nrows=50)

neat_DT <- function(x, filter_ = "top", nrows = 20, ...){
  xt <- x %>%
    as.data.frame() %>%
    DT::datatable(
      class   = 'cell-border stripe',
      filter  = filter_,
      options = list(
        pageLength = nrows,
        autoWidth  = FALSE
      ),
      ...
    )
  return(xt)
}

# Convenient alias for interactive exploration
dt <- neat_DT

# ============================================================================
# METADATA EXPLORATION UTILITY
# ============================================================================
# 
# Function: names_labels()
# Purpose: Extract variable names and their associated labels
# Learning Objective: Always understand your data structure
#
# This function helps during data exploration phases to understand
# what each variable represents, especially important when working
# with social media data that may have complex nested structures.

names_labels <- function(ds){
  dd <- as.data.frame(ds)
  
  nl <- data.frame(matrix(NA, nrow = ncol(dd), ncol = 2))
  names(nl) <- c("name", "label")
  
  for (i in seq_along(names(dd))){
    nl[i, "name"] <- attr(dd[i], "names")
    if(is.null(attr(dd[[i]], "label"))){
      nl[i, "label"] <- NA
    } else {
      nl[i, "label"] <- attr(dd[, i], "label")
    }
  }
  return(nl)
}

# ============================================================================
# LEARNING NOTES FOR CONTRIBUTORS
# ============================================================================
#
# This file demonstrates several pedagogical principles:
#
# 1. **Consistency Over Cleverness**: Simple, predictable patterns that
#    work reliably across the entire project
#
# 2. **Documentation as Teaching**: Every function explains not just what
#    it does, but why it exists and how it fits into the larger system
#
# 3. **Reusability by Design**: Functions are designed to be used across
#    multiple phases of the project (data collection, analysis, reporting)
#
# 4. **Progressive Enhancement**: Basic functionality that can be extended
#    without breaking existing code
#
# Related Learning Resources:
# - docs/human-ai-patterns.md: How these functions support collaboration
# - docs/architecture.md: Where these functions fit in the system design
# - ai/project-memory.md: Decision rationale for utility function design
#
# ============================================================================
