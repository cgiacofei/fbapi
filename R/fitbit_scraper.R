source('R/functions.R')
source('R/settings.R')
source('R/dev.R')
pkgTest('fitbitScraper')

fitbit_auth <- function(email, password){
  cookie <- fitbitScraper::login(
    email=email,
    password=password,
    rememberMe=TRUE
  )

  return(cookie)
}

scraper_get <- function(date.start, date.end, token){
  # Scrape data from fitbit website
  #
  # Inputs:
  #  - date.start: Start of date range
  #  - date.end:   End of date range
  #  - token:      Authentication token from fitbit_auth()

  LOGGABLES <- c("steps", "distance", "floors", "minutesVery",
                 "caloriesBurnedVsIntake", "getTimeInHeartRateZonesPerDay",
                 "getRestingHeartRateData")

  for (loggable in LOGGABLES) {
    if (exists("total.data")) {

      loop.data <- as.data.frame(fitbitScraper::get_daily_data(
        token,
        loggable,
        start_date="2015-10-09",
        end_date=date.end
      ))
      loop.data$time <- as.character(as.Date(loop.data$time))
      total.data <- merge(total.data, loop.data,by="time")

    } else {

      total.data <- as.data.frame(fitbitScraper::get_daily_data(
        token,
        loggable,
        start_date="2015-10-09",
        end_date=date.end
      ))
      total.data$time <- as.character(as.Date(total.data$time))
    }
  }

  # Gather Weight measurements
  weight.data <- fitbitScraper::get_weight_data(
    token,
    start_date=date.start,
    end_date=date.end
  )

  weight.data$time <- as.character(as.Date(weight.data$time) - 1)
  total.data <- merge(total.data, weight.data,by="time", all.x=TRUE)

  return(total.data)
}
