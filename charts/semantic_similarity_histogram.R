# Load required packages
library(tidyverse)

setwd("/Users/chivo/Downloads/data_studio /project4/new_yorker_contest")


# Read the updated semantic similarity file
df <- read_csv("semantic_similarity_with_matched_category.csv")

ggplot(df, aes(x = semantic_similarity, fill = ai_model)) +
  geom_histogram(alpha = 0.7, bins = 30, position = "identity") +
  facet_wrap(~ai_model) +
  scale_fill_manual(values = c("ChatGPT (gpt-4o)" = "#1f77b4", "Claude" = "#ff7f0e")) +
  theme_minimal() +
  labs(
    title = "Distribution of Semantic Similarity by AI Model",
    x = "Semantic Similarity",
    y = "Count",
    fill = "AI Model"
  )
install.packages("svglite")

ggsave("semantic_similarity_histogram.svg", width = 8, height = 5, dpi = 300)

