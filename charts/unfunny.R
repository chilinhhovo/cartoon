library(tidyverse)

# ✅ Load data from new path
df <- read_csv("/Users/chivo/Downloads/data_studio /project4/new_yorker_contest/semantic_similarity_with_matched_category.csv")

# ✅ Summarize mean similarity per contest/model
df_summary <- df %>%
  group_by(contest, ai_model) %>%
  summarise(mean_similarity = mean(semantic_similarity), .groups = "drop")

# ✅ Get top 20 contests with highest average similarity across models
top_contests <- df_summary %>%
  group_by(contest) %>%
  summarise(avg_similarity = mean(mean_similarity)) %>%
  arrange(desc(avg_similarity)) %>%
  slice_head(n = 20)
By Contest
# ✅ Filter original summary to just these contests
top_df <- df_summary %>% filter(contest %in% top_contests$contest)

# ✅ Plot
ggplot(top_df, aes(x = reorder(as.factor(contest), mean_similarity), y = mean_similarity, fill = ai_model)) +
  geom_col(position = "dodge") +
  coord_flip() +
  theme_minimal() +
  scale_fill_manual(values = c("ChatGPT (gpt-4o)" = "#d95f02", "Claude" = "#1b9e77")) +
  labs(
    title = "Top 20 Contests: Mean Semantic Similarity by AI Model",
    x = "Contest",
    y = "Mean Semantic Similarity",
    fill = "AI Model"
  )
ggsave("semantic_by_contest_cleaned.svg", width = 10, height = 8, dpi = 300)


ggplot(df_summary, aes(x = mean_similarity, y = reorder(as.factor(contest), mean_similarity), color = ai_model)) +
  geom_point(position = position_dodge(width = 0.5), size = 2) +
  theme_minimal() +
  labs(
    title = "Mean Semantic Similarity by Contest",
    x = "Mean Semantic Similarity",
    y = "Contest",
    color = "AI Model"
  ) +
  scale_color_manual(values = c("ChatGPT (gpt-4o)" = "#e41a1c", "Claude" = "#377eb8"))
ggsave("semantic_by_contest_cleaned.svg", width = 10, height = 8, dpi = 300)


library(ggrepel)

# Example: label contests with the largest model gap
# First, calculate the difference per contest
df_gap <- df_summary |>
  tidyr::pivot_wider(names_from = ai_model, values_from = mean_similarity) |>
  mutate(gap = abs(`ChatGPT (gpt-4o)` - Claude)) |>
  arrange(desc(gap))

# Select top N contests to label (you can adjust this)
top_contests_to_label <- df_gap |> slice_max(gap, n = 10) |> pull(contest)

# Add a label column to df_summary
df_summary$label <- ifelse(df_summary$contest %in% top_contests_to_label, df_summary$contest, NA)

# Now plot with labels
ggplot(df_summary, aes(x = mean_similarity, y = reorder(as.factor(contest), mean_similarity), color = ai_model)) +
  geom_point(position = position_dodge(width = 0.5), size = 2) +
  geom_text_repel(aes(label = label),
                  size = 3,
                  nudge_x = 0.02,
                  na.rm = TRUE,
                  show.legend = FALSE) +
  theme_minimal() +
  labs(
    title = "Mean Semantic Similarity by Contest",
    x = "Mean Semantic Similarity",
    y = "Contest",
    color = "AI Model"
  ) +
  scale_color_manual(values = c("ChatGPT (gpt-4o)" = "#e41a1c", "Claude" = "#377eb8"))

ggsave("semantic_by_contest_labeled.svg", width = 10, height = 8, dpi = 300)

# Load tidyverse
library(tidyverse)

# Read the dataset
df <- read_csv("/Users/chivo/Downloads/data_studio /project4/new_yorker_contest/semantic_similarity_with_matched_category.csv")

# Perform t-test
t_test_result <- t.test(
  semantic_similarity ~ ai_model,
  data = df
)

print(t_test_result)

library(tidyverse)

# Load your CSV (adjust path as needed)
df <- read_csv("/Users/chivo/Downloads/data_studio /project4/new_yorker_contest/semantic_similarity_with_matched_category.csv")

# Drop NA in category_human (just in case)
df <- df %>% filter(!is.na(category_human))

# Run Welch Two Sample t-test
t_test_category <- t.test(
  semantic_similarity ~ category_human,
  data = df,
  var.equal = FALSE
)

print(t_test_category)


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
