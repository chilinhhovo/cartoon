library(tidyverse)

# Load your dataset
df <- read_csv("combined_captions_with_hf_sentiment.csv")

# Pivot just the label columns to long format
sentiment_long <- df %>%
  select(contest, 
         sentiment_label_caption_human,
         sentiment_label_caption_chatgpt,
         sentiment_label_caption_claude) %>%
  pivot_longer(
    cols = starts_with("sentiment_label_caption_"),
    names_to = "source",
    values_to = "label"
  ) %>%
  mutate(
    model = case_when(
      source == "sentiment_label_caption_human" ~ "Human",
      source == "sentiment_label_caption_chatgpt" ~ "ChatGPT (gpt-4o)",
      source == "sentiment_label_caption_claude" ~ "Claude"
    ),
    label = case_when(
      label == "LABEL_0" ~ "Negative",
      label == "LABEL_1" ~ "Neutral",
      label == "LABEL_2" ~ "Positive"
    )
  )

# Plot the proportions
ggplot(sentiment_long, aes(x = model, fill = label)) +
  geom_bar(position = "fill") +
  scale_fill_manual(
    values = c("Negative" = "#d73027", "Neutral" = "#fdae61", "Positive" = "#1a9850")
  ) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Sentiment Distribution of Captions by Model",
    x = "Model",
    y = "Proportion of Captions",
    fill = "Sentiment"
  ) +
  theme_minimal()
