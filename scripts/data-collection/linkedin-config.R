# LinkedIn Scraping Configuration
# Agency Summer 2025 Event Impact Monitoring

# Event Configuration
EVENT_CONFIG <- list(
  name = "Agency - Summer 2025: Agentic Public Infrastructure",
  date = as.Date("2025-07-29"),
  location = "Edmonton, AB, Canada",
  hashtags = c(
    "#AgencySummer2025",
    "#AgenticPublicInfrastructure", 
    "#EdmontonAI",
    "#AlbertaAI",
    "#AIGovernment",
    "#PublicServiceAI",
    "#YEG",
    "#AICanada"
  ),
  keywords = c(
    "Agency Summer 2025",
    "Agentic Public Infrastructure",
    "Edmonton AI",
    "Alberta government AI",
    "public service artificial intelligence",
    "AI policy Canada",
    "government innovation Edmonton"
  )
)

# Target Profiles for Scraping
TARGET_PROFILES <- list(
  mykodev = "https://www.linkedin.com/in/mykodev/",
  janak_alford = "https://www.linkedin.com/in/janak-alford/",
  jean_paul_lalonde = "https://www.linkedin.com/in/jean-paullalonde/",
  julieish = "https://www.linkedin.com/in/julieish/"
)

# Scraping Parameters
SCRAPING_CONFIG <- list(
  # Rate limiting
  min_delay_seconds = 3,
  max_delay_seconds = 8,
  profile_break_min = 5,
  profile_break_max = 12,
  
  # Browser settings
  window_width = 1366,
  window_height = 768,
  user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
  
  # Content limits
  max_posts_per_profile = 50,
  max_scroll_attempts = 5,
  page_load_wait = 3,
  
  # Data collection scope
  collect_engagement_metrics = TRUE,
  collect_hashtags = TRUE,
  collect_mentions = TRUE,
  collect_profile_info = TRUE,
  
  # Privacy settings
  anonymize_names = TRUE,
  anonymize_urls = TRUE,
  store_raw_data = FALSE  # Set to TRUE for development/debugging
)

# Ethical Guidelines
ETHICS_CONFIG <- list(
  respect_robots_txt = TRUE,
  public_content_only = TRUE,
  no_personal_data = TRUE,
  rate_limit_strict = TRUE,
  attribution_required = TRUE,
  
  # Content filtering
  exclude_personal_posts = TRUE,
  focus_on_professional_content = TRUE,
  event_relevance_required = FALSE,  # Set to TRUE to only save event-related posts
  
  # Legal compliance
  fair_use_only = TRUE,
  research_purpose_only = TRUE,
  no_commercial_use = TRUE
)

# Output Configuration  
OUTPUT_CONFIG <- list(
  # File paths
  raw_data_dir = "data-private/raw",
  processed_data_dir = "data-private/derived", 
  logs_dir = "data-private/logs",
  
  # File naming
  filename_prefix = "linkedin_agency2025",
  include_timestamp = TRUE,
  include_profile_count = TRUE,
  
  # Data formats
  save_rds = TRUE,
  save_csv = TRUE,
  save_json = FALSE,
  
  # Summary outputs
  generate_summary = TRUE,
  generate_engagement_report = TRUE,
  generate_hashtag_cloud = TRUE
)

# Analysis Configuration
ANALYSIS_CONFIG <- list(
  # Text analysis
  extract_hashtags = TRUE,
  extract_mentions = TRUE,
  extract_urls = TRUE,
  sentiment_analysis = FALSE,  # Will be implemented in Issue #3
  
  # Network analysis
  build_mention_network = TRUE,
  build_hashtag_network = TRUE,
  calculate_influence_metrics = TRUE,
  
  # Temporal analysis
  track_posting_patterns = TRUE,
  identify_trending_topics = TRUE,
  measure_engagement_evolution = TRUE
)

# Validation Rules
VALIDATION_CONFIG <- list(
  # Profile validation
  min_profile_completeness = 0.7,  # 70% of expected fields
  require_recent_activity = TRUE,
  max_days_since_activity = 30,
  
  # Post validation
  min_post_length = 10,  # Minimum characters
  max_post_age_days = 60,  # Only posts from last 60 days
  require_engagement_data = FALSE,
  
  # Content quality
  filter_spam = TRUE,
  filter_promotional = TRUE,
  filter_irrelevant = TRUE,
  
  # Data quality
  check_encoding = TRUE,
  validate_dates = TRUE,
  clean_html = TRUE
)
