library('googlesheets')
suppressPackageStartupMessages(library('dplyr'))

fitbit <- gs_title("Fitbit Data")

data <- gs_read(fitbit,)

