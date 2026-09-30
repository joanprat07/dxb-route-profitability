# =============================================================================
# 06_evaluation.R — master equation, prediction intervals, residual diagnostics
# =============================================================================
source("R/00_setup.R")
obj <- readRDS(file.path(OUT_DIR, "final_model.rds"))
model_final5 <- obj$model_final5; test_data <- obj$test_data

# ---- Master equation --------------------------------------------------------
print(summary(model_final5))
print(coef(model_final5))

# ---- Prediction power assessment --------------------------------------------
pred_test <- as.data.frame(predict(model_final5, newdata = test_data,
                                   interval = "prediction", level = 0.95))
pred_test$Actual <- test_data$Profit
pred_test$Inside <- pred_test$Actual >= pred_test$lwr & pred_test$Actual <= pred_test$upr
pred_test <- pred_test[order(pred_test$fit), ]
pred_test$Flight <- seq_len(nrow(pred_test))
cat("Prediction interval coverage:", round(100 * mean(pred_test$Inside), 2), "%\n")

# Structure of the 95% prediction interval
save_plot(
  ggplot(pred_test, aes(Flight)) +
    geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "lightblue") +
    geom_line(aes(y = fit), colour = "blue") +
    labs(title = "Structure of the 95% Prediction Interval (Model Final 5)",
         x = "Test flights (ordered by predicted profit)", y = "Profit ($)") +
    money_y,
  "Prediction_Interval_ModelF5.png", 9, 5)

# Prediction intervals vs actual profit
save_plot(
  ggplot(pred_test, aes(Flight)) +
    geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "lightblue") +
    geom_point(aes(y = Actual, colour = ifelse(Inside, "Inside", "Outside")), size = 0.8) +
    scale_colour_manual(values = c(Inside = "green4", Outside = "red")) +
    labs(title = "Final Model Reliability: 95% Prediction Interval vs Actual Profit",
         x = "Test flights (ordered by predicted profit)", y = "Profit ($)",
         colour = "Actual profit") +
    money_y,
  "Prediction_Interval_Coverage_ModelF5.png", 9, 5)

# ---- Residual diagnostics ---------------------------------------------------
save_base_plot("Residuals_vs_Fitted_ModelF5.png", plot(model_final5, which = 1))
save_base_plot("Residuals_vs_Leverage_ModelF5.png",          plot(model_final5, which = 5))
save_base_plot("QQ_Plot_ModelF5.png",               plot(model_final5, which = 2))

capture.output(summary(model_final5), mean(pred_test$Inside),
               file = file.path(OUT_DIR, "final_model_5.txt"))
