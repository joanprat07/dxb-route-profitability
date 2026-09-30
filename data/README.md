# Data

Source: [Airline Route Profitability and Cost Analysis](https://www.kaggle.com/datasets/waleedfaheem/airline-route-profitability-and-cost-analysis) (Kaggle).

The scripts use the cleaned version of the dataset produced during the course
(7,182 flights, 34 variables), saved in this folder as `vols_dubai_nets.csv`.
The raw Kaggle file (7,974 flights) needs the cleaning described in the main README
before it matches this version. The data file itself is not included in the repository.

Required columns: `Profit`, `Ticket_Revenue`, `Ancillary_Revenue`, `Fuel_Cost`,
`Passengers`, `Flight_Hours`, `Load_Factor`, `Season`, `Route_Category`,
`Aircraft_Type` and `Demand_Level`.

Run `Rscript run_all.R` from the repository root.
