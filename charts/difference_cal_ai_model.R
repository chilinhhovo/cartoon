library(dplyr)
library(readr)

# Load the data
df <- read_csv("semantic_similarity_with_matched_category.csv")

# Calculate mean similarity per contest and model
gap_df <- df %>%
  group_by(contest, ai_model) %>%
  summarise(mean_similarity = mean(semantic_similarity, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = ai_model, values_from = mean_similarity) %>%
  mutate(gap = abs(`ChatGPT (gpt-4o)` - Claude)) %>%
  arrange(desc(gap))

# View top 10 contests with the biggest model difference
head(gap_df, 10)
write_csv(gap_df, "contests_with_biggest_model_difference.csv")