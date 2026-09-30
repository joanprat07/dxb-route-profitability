# =============================================================================
# 03_hypothesis_tests.R — hypothesis testing
# =============================================================================
source("R/00_setup.R")
data_clean <- readRDS(file.path(OUT_DIR, "data.rds"))$data_clean

# Hypothesis 1: Profit differences by Route Category (one-way ANOVA)
anova_route <- aov(Profit ~ Route_Category, data = data_clean)
print(summary(anova_route))

# Hypothesis 2: Profit differences by Season (one-way ANOVA)
anova_season <- aov(Profit ~ Season, data = data_clean)
print(summary(anova_season))

# Hypothesis 3: Association between Season and Demand Level (chi-squared)
season_demand <- table(data_clean$Season, data_clean$Demand_Level)
chi_test <- chisq.test(season_demand)
print(chi_test)

save_base_plot("Season_vs_Demand_Level.png", {
  mosaicplot(season_demand, main = "Season vs Demand Level",
             xlab = "Season", ylab = "Demand Level", color = TRUE)
})

capture.output(summary(anova_route), summary(anova_season), chi_test,
               file = file.path(OUT_DIR, "hypothesis_tests.txt"))
