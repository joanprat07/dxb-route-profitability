# Run the full analysis from the repository root: Rscript run_all.R
for (s in c("R/01_cleaning.R", "R/02_eda.R", "R/03_hypothesis_tests.R",
            "R/04_regression.R", "R/05_final_models.R", "R/06_evaluation.R")) {
  cat("\n=====", s, "=====\n")
  source(s, local = new.env())
}
