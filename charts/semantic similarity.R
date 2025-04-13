library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)

# Load your CSV
df <- read_csv("contests_with_model_winner.csv")

# Create output folder
output_folder <- "similarity_values"
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# Reshape to long format
df_long <- df %>%
  pivot_longer(cols = c(`ChatGPT (gpt-4o)`, Claude),
               names_to = "model",
               values_to = "similarity")

# Loop through contests
for (contest_id in unique(df$contest)) {
  plot_data <- df_long %>% filter(contest == contest_id)
  winner <- df %>% filter(contest == contest_id) %>% pull(Who_won)
  description <- df %>% filter(contest == contest_id) %>% pull(Description)
  
  p <- ggplot(plot_data, aes(x = similarity, y = model, fill = model)) +
    geom_col(width = 0.5, show.legend = FALSE) +
    geom_text(aes(label = round(similarity, 3)), hjust = -0.1, size = 4) +
    scale_fill_manual(values = c("ChatGPT (gpt-4o)" = "#74AA9C", "Claude" = "#DA7859")) +
    labs(
      title = paste("Contest", contest_id, "-", winner, "won"),
      subtitle = description,
      x = "Mean Semantic Similarity",
      y = NULL
    ) +
    theme_minimal(base_size = 14) +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    xlim(0, max(df_long$similarity, na.rm = TRUE) + 0.05)
  
  ggsave(
    filename = file.path(output_folder, paste0(contest_id, ".svg")),
    plot = p,
    width = 7,
    height = 4,
    dpi = 300
  )
}
