# =============================================================================
# 05_final_models.R — look-ahead bias, auxiliary models and Final Models 1-5
# =============================================================================
source("R/00_setup.R")
d <- readRDS(file.path(OUT_DIR, "data.rds"))
train_data <- d$train_data; test_data <- d$test_data

# ---- Phase 3: Auxiliary prediction models -----------------------------------
# Ancillary Revenue prediction models
model_ancillary1 <- lm(Ancillary_Revenue ~ Passengers + Flight_Hours + Season +
                         Route_Category, data = train_data)
model_ancillary2 <- lm(Ancillary_Revenue ~ Passengers + Flight_Hours + Season,
                       data = train_data)
print(AIC(model_ancillary1, model_ancillary2))

# Fuel Cost prediction models
model_Fuel1 <- lm(Fuel_Cost ~ Load_Factor + Passengers + Aircraft_Type +
                    Flight_Hours + Route_Category, data = train_data)
model_Fuel2 <- lm(Fuel_Cost ~ Load_Factor + Passengers + Aircraft_Type +
                    Flight_Hours, data = train_data)
print(AIC(model_Fuel1, model_Fuel2))

aux_plot <- function(model, target, title) {
  df <- data.frame(Actual = test_data[[target]], Predicted = predict(model, test_data))
  ggplot(df, aes(Actual, Predicted)) +
    geom_point(alpha = 0.3, size = 1) +
    geom_abline(slope = 1, intercept = 0, colour = "red") +
    labs(title = title, x = paste("Actual", target), y = paste("Predicted", target)) +
    money_x + money_y
}
save_plot(aux_plot(model_ancillary1, "Ancillary_Revenue", "Ancillary Model 1"), "Model_Ancillary1.png", 6, 5)
save_plot(aux_plot(model_ancillary2, "Ancillary_Revenue", "Ancillary Model 2"), "Model_Ancillary2.png", 6, 5)
save_plot(aux_plot(model_Fuel1, "Fuel_Cost", "Fuel Model 1"), "Model_Fuel1.png", 6, 5)
save_plot(aux_plot(model_Fuel2, "Fuel_Cost", "Fuel Model 2"), "Model_Fuel2.png", 6, 5)

# Selected auxiliary models (lower AIC: Model 1 in both cases)
model_ancillary <- model_ancillary1
model_Fuel      <- model_Fuel1

# Generate predicted values for train and test sets
train_data$Pred_Ancillary <- predict(model_ancillary, train_data)
train_data$Pred_Fuel      <- predict(model_Fuel, train_data)
test_data$Pred_Ancillary  <- predict(model_ancillary, test_data)
test_data$Pred_Fuel       <- predict(model_Fuel, test_data)

# ---- Phase 4: Final model construction --------------------------------------
# Final Model 1: direct substitution into Model C
model_final1 <- lm(Profit ~ Passengers + Flight_Hours + Pred_Ancillary + Pred_Fuel +
                     Ticket_Revenue + Season + Route_Category + Aircraft_Type +
                     Demand_Level, data = train_data)
print(anova(model_final1))
print(tryCatch(vif(model_final1), error = function(e) conditionMessage(e)))

# Final Model 2: removing redundant variables
model_final2 <- lm(Profit ~ Passengers + Flight_Hours + Pred_Fuel + Ticket_Revenue,
                   data = train_data)
# Final Model 3: replacing Passengers and Flight Hours with Pred_Ancillary
model_final3 <- lm(Profit ~ Pred_Fuel + Pred_Ancillary + Ticket_Revenue + Demand_Level,
                   data = train_data)
# Final Model 4: removing Demand Level
model_final4 <- lm(Profit ~ Pred_Fuel + Pred_Ancillary + Ticket_Revenue,
                   data = train_data)
# Final Model 5: simplest viable model
model_final5 <- lm(Profit ~ Pred_Fuel + Ticket_Revenue, data = train_data)

# Partial regression plots
save_base_plot("Partial_ModelF2.png", avPlots(model_final2), 1400, 1000)
save_base_plot("Partial_ModelF3.png", avPlots(model_final3), 1400, 1000)
save_base_plot("Partial_ModelF4.png", avPlots(model_final4), 1400, 1000)
save_base_plot("Partial_ModelF5.png", avPlots(model_final5), 1400, 1000)

# ---- Phase 5: Final model comparison ----------------------------------------
evaluate <- function(model) {
  pred_test <- predict(model, newdata = test_data, interval = "prediction", level = 0.95)
  mae    <- mean(abs(test_data$Profit - pred_test[, "fit"]))
  rmse   <- sqrt(mean((test_data$Profit - pred_test[, "fit"])^2))
  ss_res <- sum((test_data$Profit - pred_test[, "fit"])^2)
  ss_tot <- sum((test_data$Profit - mean(test_data$Profit))^2)
  r2_test <- 1 - ss_res / ss_tot
  inside <- test_data$Profit >= pred_test[, "lwr"] & test_data$Profit <= pred_test[, "upr"]
  c(MAE = mae, RMSE = rmse, R2_test = r2_test, Coverage95 = mean(inside),
    Avg_PI_Width = mean(pred_test[, "upr"] - pred_test[, "lwr"]), AIC_train = AIC(model))
}
finals <- list(`Final 1` = model_final1, `Final 2` = model_final2,
               `Final 3` = model_final3, `Final 4` = model_final4,
               `Final 5` = model_final5)
table11 <- do.call(rbind, lapply(finals, evaluate))
print(round(table11, 4))
write.csv(table11, file.path(OUT_DIR, "final_models_comparison.csv"))

# VIF comparison, Final Models 2-5
vif_comparison <- lapply(finals[2:5], vif)
print(vif_comparison)

capture.output(AIC(model_ancillary1, model_ancillary2), AIC(model_Fuel1, model_Fuel2),
               anova(model_final1), round(table11, 4), vif_comparison,
               file = file.path(OUT_DIR, "final_models.txt"))

saveRDS(list(model_final5 = model_final5, test_data = test_data),
        file.path(OUT_DIR, "final_model.rds"))
