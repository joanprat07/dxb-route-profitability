# =============================================================================
# 00_setup.R — packages, paths and plotting helpers
# =============================================================================
library(ggplot2)
library(corrplot)
library(car)

theme_set(theme_minimal(base_size = 12))
money_x <- scale_x_continuous(labels = scales::comma)
money_y <- scale_y_continuous(labels = scales::comma)

DATA_FILE  <- file.path("data", "vols_dubai_nets.csv")
FIG_DIR    <- "figures"
OUT_DIR    <- "outputs"
dir.create(FIG_DIR, showWarnings = FALSE)
dir.create(OUT_DIR, showWarnings = FALSE)

save_plot <- function(p, name, width = 8, height = 5) {
  ggsave(file.path(FIG_DIR, name), p, width = width, height = height,
         dpi = 150, bg = "white")
}

save_base_plot <- function(name, expr, width = 1200, height = 800) {
  png(file.path(FIG_DIR, name), width = width, height = height, res = 130)
  on.exit(dev.off())
  force(expr)
}

pred_vs_actual_plot <- function(model, data, title) {
  df <- data.frame(Actual = data$Profit, Predicted = predict(model, newdata = data))
  ggplot(df, aes(Actual, Predicted)) +
    geom_point(alpha = 0.3, size = 1) +
    geom_abline(slope = 1, intercept = 0, colour = "red") +
    labs(title = title, x = "Actual Profit ($)", y = "Predicted Profit ($)") +
    money_x + money_y
}
