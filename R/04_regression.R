# =============================================================================
# 04_regression.R — simple and multiple linear regression (Models 1-3, A-C)
# =============================================================================
source("R/00_setup.R")
d <- readRDS(file.path(OUT_DIR, "data.rds"))
train_data <- d$train_data; test_data <- d$test_data

# ---- Phase 1: Simple linear regression models -------------------------------
# Model 1: Passengers
model_1 <- lm(Profit ~ Passengers, data = train_data)
# Model 2: Ancillary Revenue
model_2 <- lm(Profit ~ Ancillary_Revenue, data = train_data)
# Model 3: Ticket Revenue
model_3 <- lm(Profit ~ Ticket_Revenue, data = train_data)

save_plot(pred_vs_actual_plot(model_1, test_data, "Model 1: Predicted vs Actual Profit (Passengers)"),
          "Model_1_Passengers.png", 6, 5)
save_plot(pred_vs_actual_plot(model_2, test_data, "Model 2: Predicted vs Actual Profit (Ancillary Revenue)"),
          "Model_2_Ancillary_Revenue.png", 6, 5)
save_plot(pred_vs_actual_plot(model_3, test_data, "Model 3: Predicted vs Actual Profit (Ticket Revenue)"),
          "Model_3_Ticket_Revenue.png", 6, 5)

# ---- Phase 2: Multiple linear regression models -----------------------------
# Model A: Numerical variables only
model_A <- lm(Profit ~ Passengers + Flight_Hours +
                Ancillary_Revenue + Fuel_Cost + Ticket_Revenue,
              data = train_data)

# Model B: Adding Season and Route Category
model_B <- lm(Profit ~ Passengers + Flight_Hours +
                Ancillary_Revenue + Fuel_Cost + Ticket_Revenue +
                Season + Route_Category, data = train_data)

# Model C: Full feature set
model_C <- lm(Profit ~ Passengers + Flight_Hours +
                Ancillary_Revenue + Fuel_Cost + Ticket_Revenue +
                Season + Route_Category + Aircraft_Type +
                Demand_Level, data = train_data)

# AIC comparison
aic_ABC <- AIC(model_A, model_B, model_C)
print(aic_ABC)

# ANOVA on Model C
anova_C <- anova(model_C)
print(anova_C)

save_plot(pred_vs_actual_plot(model_A, test_data, "Model A: Predicted vs Actual Profit"),
          "Model_A.png", 6, 5)
save_plot(pred_vs_actual_plot(model_B, test_data, "Model B: Predicted vs Actual Profit"),
          "Model_B.png", 6, 5)
save_plot(pred_vs_actual_plot(model_C, test_data, "Model C: Predicted vs Actual Profit"),
          "Model_C.png", 6, 5)

capture.output(aic_ABC, anova_C, summary(model_C),
               file = file.path(OUT_DIR, "models_ABC.txt"))
