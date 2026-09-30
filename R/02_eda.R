# =============================================================================
# 02_eda.R — descriptive analysis and exploratory data analysis
# =============================================================================
source("R/00_setup.R")
data_clean <- readRDS(file.path(OUT_DIR, "data.rds"))$data_clean

skewness <- function(x) mean((x - mean(x))^3) / sd(x)^3
season_order <- c("Low", "Normal", "Shoulder", "Peak")
data_clean$Season_plot <- factor(data_clean$Season, levels = season_order)

# ---- Distribution of Net Profit ---------------------------------------------
q <- quantile(data_clean$Profit, c(0, 0.25, 0.5, 0.75, 1))
profit_summary <- data.frame(
  Statistic = c("Mean", "Standard Deviation", "Minimum", "1st Quartile",
                "Median", "3rd Quartile", "Maximum", "Skewness"),
  Value = c(mean(data_clean$Profit), sd(data_clean$Profit), q[1], q[2], q[3],
            q[4], q[5], skewness(data_clean$Profit)))
print(profit_summary)
write.csv(profit_summary, file.path(OUT_DIR, "profit_summary.csv"), row.names = FALSE)

save_plot(
  ggplot(data_clean, aes(Profit)) +
    geom_histogram(bins = 50, fill = "steelblue", colour = "white") +
    labs(title = "Distribution of Net Profit per Flight", x = "Net Profit ($)", y = "Frequency") +
    money_x,
  "Distribution_of_Net_Profit_per_Flight.png")

# ---- Profitability by Route Category ----------------------------------------
route_stats <- do.call(rbind, lapply(split(data_clean$Profit, data_clean$Route_Category),
  function(x) data.frame(n = length(x), Mean = mean(x), Min = min(x), Max = max(x))))
route_stats <- cbind(Route_Category = rownames(route_stats), route_stats)
print(route_stats, row.names = FALSE)
write.csv(route_stats, file.path(OUT_DIR, "profit_by_route.csv"), row.names = FALSE)

save_plot(
  ggplot(data_clean, aes(Route_Category, Profit, fill = Route_Category)) +
    geom_boxplot(show.legend = FALSE) +
    labs(title = "Net Profit by Route Category", x = "Route Category", y = "Net Profit ($)") +
    money_y,
  "Net_Profit_by_Route_Category.png")

# ---- Profitability by Aircraft Type -----------------------------------------
save_plot(
  ggplot(data_clean, aes(Aircraft_Type, Profit, fill = Aircraft_Type)) +
    geom_boxplot(show.legend = FALSE) +
    labs(title = "Net Profit by Aircraft Type", x = "Aircraft Type", y = "Net Profit ($)") +
    money_y +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)),
  "Net_Profit_by_Aircraft_Type_Boxplot.png")

# ---- Impact of Seasonality --------------------------------------------------
season_avg <- aggregate(Profit ~ Season_plot, data_clean, mean)
save_plot(
  ggplot(season_avg, aes(Season_plot, Profit)) +
    geom_col(fill = "steelblue") +
    labs(title = "Average Net Profit by Season", x = "Season", y = "Average Net Profit ($)") +
    money_y,
  "Average_Net_Profit_by_Season.png")

season_loss <- aggregate(Loss ~ Season_plot,
                         transform(data_clean, Loss = as.numeric(Status_Profit == "Loss")), mean)
save_plot(
  ggplot(season_loss, aes(Season_plot, Loss * 100)) +
    geom_col(fill = "firebrick") +
    labs(title = "Loss Rate by Season", x = "Season", y = "Loss-making flights (%)"),
  "Loss_Rate_by_Season.png")

# ---- Descriptive statistics of key numerical variables ----------------------
num_vars <- c("Ancillary_Revenue", "Passengers", "Fuel_Cost", "Flight_Hours")
table6 <- data.frame(Variable = num_vars,
                     Mean     = sapply(data_clean[num_vars], mean),
                     Std_Dev  = sapply(data_clean[num_vars], sd),
                     Skewness = sapply(data_clean[num_vars], skewness))
print(table6, row.names = FALSE)
write.csv(table6, file.path(OUT_DIR, "numeric_descriptives.csv"), row.names = FALSE)

# ---- Distribution of key categorical variables ------------------------------
table7 <- do.call(rbind, lapply(c("Season", "Demand_Level", "Aircraft_Type"), function(v) {
  t <- sort(table(data_clean[[v]]), decreasing = TRUE)
  data.frame(Variable = v, Category = names(t), n = as.integer(t),
             Percentage = round(100 * as.numeric(t) / sum(t), 2))
}))
print(table7, row.names = FALSE)
write.csv(table7, file.path(OUT_DIR, "categorical_distribution.csv"), row.names = FALSE)

# ---- Correlation analysis ---------------------------------------------------
cor_vars <- c("Profit", "Ancillary_Revenue", "Ticket_Revenue", "Passengers",
              "Fuel_Cost", "Flight_Hours")
cor_matrix <- cor(data_clean[cor_vars])
print(round(cor_matrix, 2))
write.csv(round(cor_matrix, 2), file.path(OUT_DIR, "correlation_matrix.csv"))
save_base_plot("Correlation_Matrix.png", {
  corrplot(cor_matrix, method = "color", addCoef.col = "black", tl.col = "black")
}, width = 1000, height = 1000)

# ---- Route Category x Season ------------------------------------------------
route_season <- aggregate(Profit ~ Route_Category + Season_plot, data_clean, mean)
save_plot(
  ggplot(route_season, aes(Season_plot, Profit, fill = Route_Category)) +
    geom_col(position = "dodge") +
    labs(title = "Average Net Profit by Route Category and Season",
         x = "Season", y = "Average Net Profit ($)", fill = "Route Category") +
    money_y,
  "Average_Net_Profit_by_Route_Category_and_Season.png")

route_season_loss <- aggregate(Loss ~ Route_Category + Season_plot,
                               transform(data_clean, Loss = as.numeric(Status_Profit == "Loss")),
                               mean)
save_plot(
  ggplot(route_season_loss, aes(Season_plot, Loss * 100, fill = Route_Category)) +
    geom_col(position = "dodge") +
    labs(title = "Loss Rate by Route Category and Season",
         x = "Season", y = "Loss-making flights (%)", fill = "Route Category"),
  "Loss_Rate_by_Route_Category_and_Season.png")

# ---- Aircraft Type bar chart ------------------------------------------------
aircraft_avg <- aggregate(Profit ~ Aircraft_Type, data_clean, mean)
save_plot(
  ggplot(aircraft_avg, aes(reorder(Aircraft_Type, -Profit), Profit)) +
    geom_col(fill = "steelblue") +
    labs(title = "Average Net Profit by Aircraft Type", x = "Aircraft Type",
         y = "Average Net Profit ($)") +
    money_y +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)),
  "Average_Net_Profit_by_Aircraft_Type.png")

# ---- Revenue and cost structure ---------------------------------------------
table8 <- aggregate(cbind(Ticket_Revenue, Ancillary_Revenue, Total_Revenue,
                          Fuel_Cost, Total_Cost, Profit) ~ Route_Category,
                    data_clean, mean)
print(table8)
write.csv(table8, file.path(OUT_DIR, "revenue_cost_structure.csv"), row.names = FALSE)
