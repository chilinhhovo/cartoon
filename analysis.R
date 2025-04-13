# Load required libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(corrplot)
library(ggthemes)

# Check directory structure
print("Checking directory structure...")
print("Current working directory:")
print(getwd())
print("\nContents of current directory:")
print(list.files())
print("\nContents of contest_pages directory:")
print(list.files("contest_pages"))

# Function to read contest data
read_contest_data <- function(contest_number) {
  # Read the CSV file
  csv_file <- paste0("contest_pages/contest_", contest_number, ".csv")
  if (!file.exists(csv_file)) {
    message(paste("File not found:", csv_file))
    return(NULL)
  }
  
  tryCatch({
    data <- read.csv(csv_file)
    # Print column names for debugging
    message(paste("Columns in contest", contest_number, ":", paste(names(data), collapse = ", ")))
    
    # Check if required columns exist
    required_cols <- c("sentiment", "similarity", "source")
    missing_cols <- required_cols[!required_cols %in% names(data)]
    if (length(missing_cols) > 0) {
      message(paste("Missing columns in contest", contest_number, ":", paste(missing_cols, collapse = ", ")))
      return(NULL)
    }
    
    data$contest_number <- contest_number
    return(data)
  }, error = function(e) {
    message(paste("Error reading contest", contest_number, ":", e$message))
    return(NULL)
  })
}

# First, let's check if we can read a single file
print("\nTesting file reading with contest 510...")
test_file <- "contest_pages/contest_510.csv"
if (file.exists(test_file)) {
  print(paste("File exists:", test_file))
  test_data <- read.csv(test_file)
  print("File contents:")
  print(str(test_data))
  print("\nFirst few rows:")
  print(head(test_data))
} else {
  print(paste("File does not exist:", test_file))
}

# Read all contest data
print("\nAttempting to read all contest files...")
contest_numbers <- 510:895
all_data_list <- lapply(contest_numbers, read_contest_data)

# Count successful reads
successful_reads <- sum(!sapply(all_data_list, is.null))
print(paste("\nSuccessfully read", successful_reads, "out of", length(contest_numbers), "files"))

# Combine successful reads
all_data <- do.call(rbind, all_data_list[!sapply(all_data_list, is.null)])

# Check if we have any data
if (is.null(all_data) || nrow(all_data) == 0) {
  stop("No data was successfully loaded. Please check the CSV files and their structure.")
}

# Print data structure
print("\nData Structure:")
str(all_data)

# Print first few rows
print("\nFirst few rows of data:")
print(head(all_data))

# 1. Basic Statistics
print("\nBasic Statistics:")
print(summary(all_data))

# 2. Correlation Analysis
# Check if columns exist before correlation
if (all(c("sentiment", "similarity") %in% names(all_data))) {
  correlation_matrix <- cor(all_data[, c("sentiment", "similarity")], use = "complete.obs")
  print("\nCorrelation Matrix:")
  print(correlation_matrix)
} else {
  print("\nCannot perform correlation analysis: required columns missing")
}

# 3. Time Series Analysis
# Create time series plot of average sentiment over time
if ("sentiment" %in% names(all_data)) {
  sentiment_time_series <- all_data %>%
    group_by(contest_number) %>%
    summarise(avg_sentiment = mean(sentiment, na.rm = TRUE))
  
  ggplot(sentiment_time_series, aes(x = contest_number, y = avg_sentiment)) +
    geom_line() +
    geom_smooth(method = "loess", color = "red") +
    theme_minimal() +
    labs(title = "Average Sentiment Over Time",
         x = "Contest Number",
         y = "Average Sentiment") +
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave("sentiment_time_series.png", width = 10, height = 6)
}

# 4. AI Model Performance Analysis
if (all(c("source", "sentiment", "similarity") %in% names(all_data))) {
  model_performance <- all_data %>%
    group_by(source) %>%
    summarise(
      avg_sentiment = mean(sentiment, na.rm = TRUE),
      avg_similarity = mean(similarity, na.rm = TRUE),
      n = n()
    )
  
  print("\nModel Performance:")
  print(model_performance)
  
  # Create boxplot of sentiment by model
  ggplot(all_data, aes(x = source, y = sentiment)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Sentiment Distribution by Model",
         x = "Model",
         y = "Sentiment") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave("model_sentiment_boxplot.png", width = 10, height = 6)
}

# 5. Regression Analysis
if (all(c("sentiment", "similarity") %in% names(all_data))) {
  model <- lm(similarity ~ sentiment, data = all_data)
  print("\nRegression Analysis:")
  print(summary(model))
  
  # Create scatter plot with regression line
  ggplot(all_data, aes(x = sentiment, y = similarity)) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = "lm", color = "red") +
    theme_minimal() +
    labs(title = "Sentiment vs Similarity",
         x = "Sentiment",
         y = "Similarity")
  
  ggsave("sentiment_similarity_scatter.png", width = 10, height = 6)
}

# Export summary statistics to CSV
if (exists("model_performance")) {
  write.csv(model_performance, "model_performance_summary.csv", row.names = FALSE)
}
if (exists("sentiment_time_series")) {
  write.csv(sentiment_time_series, "sentiment_time_series.csv", row.names = FALSE)
} 