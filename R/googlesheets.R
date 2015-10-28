source('R/dev.R')
source('R/functions.R')
pkgTest('googlesheets')

# pkgTest('httr') # load package for http communication

fitbit <- gs_title("Fitbit Data")

data <- gs_read(fitbit,)
