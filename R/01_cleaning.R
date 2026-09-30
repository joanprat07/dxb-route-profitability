# =============================================================================
# 01_cleaning.R — data loading, cleaning and train-test split
# =============================================================================
source("R/00_setup.R")

# Load the data
if (!file.exists(DATA_FILE)) {
  stop("Dataset not found at ", DATA_FILE, ". See data/README.md.")
}
data_raw <- read.csv(DATA_FILE, stringsAsFactors = TRUE)

# Check that the columns used in the analysis are present
required_cols <- c("Profit", "Ticket_Revenue", "Ancillary_Revenue", "Fuel_Cost",
                   "Passengers", "Flight_Hours", "Load_Factor", "Season",
                   "Route_Category", "Aircraft_Type", "Demand_Level")
missing_cols <- setdiff(required_cols, names(data_raw))
if (length(missing_cols) > 0) {
  stop("Missing columns in the dataset: ", paste(missing_cols, collapse = ", "))
}
cat("Raw data dimensions:", dim(data_raw), "\n")

# Remove missing values
data_clean <- na.omit(data_raw)
cat("After missing value removal:", dim(data_clean), "\n")

# Remove duplicates
data_clean <- data_clean[!duplicated(data_clean), ]
cat("After duplicate removal:", dim(data_clean), "\n")

# Create derived variable: Profit Status
data_clean$Status_Profit <- ifelse(data_clean$Profit >= 0, "Gain", "Loss")
data_clean$Status_Profit <- as.factor(data_clean$Status_Profit)

# Reference categories
data_clean$Season        <- relevel(data_clean$Season, ref = "Normal")
data_clean$Demand_Level  <- relevel(data_clean$Demand_Level, ref = "Medium")
data_clean$Aircraft_Type <- relevel(data_clean$Aircraft_Type, ref = "Airbus A320")

cat("Clean data dimensions:", dim(data_clean), "\n")

# Train-test split (80/20, seed 123)
set.seed(123)
n <- nrow(data_clean)
train_idx  <- sample(1:n, size = floor(0.8 * n))
train_data <- data_clean[train_idx, ]
test_data  <- data_clean[-train_idx, ]

cat("Training set:", nrow(train_data), "observations\n")
cat("Test set:", nrow(test_data), "observations\n")

saveRDS(list(data_clean = data_clean, train_data = train_data, test_data = test_data),
        file.path(OUT_DIR, "data.rds"))
