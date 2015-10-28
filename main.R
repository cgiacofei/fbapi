# a simple Oauth2.0 connection with Fitbit API
install.packages("httr") # install if not installed
library("httr") # load package for http communication

fitbit <- gs_title("Fitbit Data")

data <- gs_read(fitbit,)
