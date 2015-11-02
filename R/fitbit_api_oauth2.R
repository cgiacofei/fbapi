#------------------------------------------------------------------------------
# fitbit_api_oauth2.R
#
# Functions for authenticating with Fitbit and parsing data
#------------------------------------------------------------------------------

source('R/functions.R')

RESOURCES <- c(
  calorieOut='activities/calories',
  activityCalories='activities/activityCalories',
  steps='activities/steps',
  distance='activities/distance',
  floors='activities/floors',
  minutesSedentary='activities/minutesSedentary',
  minutesLightly='activities/minutesLightlyActive',
  minutesFairly='activities/minutesFairlyActive',
  minutesVery='activities/minutesVeryActive',
  heartRate='activities/heart',
  weight='body/log/weight',
  nutrition='foods/log'
)

API_URL <- 'https://api.fitbit.com/1/user/-/'

api_auth <- function(clientID){
  # construct string to put in GET request for authentication
  oauthString <-
    paste0("https://www.fitbit.com/oauth2/authorize?response_type=token",
           "&client_id=",
           clientID,
           "&redirect_uri=http%3A%2F%2Flocalhost%3A1410",
           "&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight",
           "&expires_in=604800")
  # print out the generated string
  cat(oauthString)
}

get_activity <- function(what, date.start, date.end, token){
  # Fetch Fitbit activity time series data
  #
  # Inputs:
  #  - what:       Resource name to pull
  #  - date.start: First date in range to pull
  #  - date.end:   Last date in range to pull
  #  - token:      OAuth2.0 access token

  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, add_headers("Authorization"= token))

  nutrition.df <- as.data.frame(do.call(rbind, httr::content(request)[[1]]))
  nutrition.df$dateTime <- as.character(nutrition.df$dateTime, is.factor=FALSE)

  names(nutrition.df) <- c('time', what)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

get_heart <- function(date.start, date.end, token){
  # Fetch Fitbit heart rate data
  #
  # Inputs:
  #  - date.start: First date in range to pull
  #  - date.end:   Last date in range to pull
  #  - token:      OAuth2.0 access token

  what <- 'heartRate'
  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, add_headers("Authorization"= token))

  # This seems hacky but it works.
  data <- jsonlite::fromJSON(jsonlite::toJSON(httr::content(request)))

  # Extract resting heart rate.
  # Eventually want heart rate zone data but that will take some
  # additional processing.
  nutrition.df <- data$`activities-heart`[1]
  nutrition.df$RHR <- data[[1]]$value$restingHeartRate

  names(nutrition.df) <- c('time', what)
  nutrition.df$time <- as.character(nutrition.df$time, is.factor=FALSE)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

get_weight <- function(date.start, date.end, token){
  # Fetch Fitbit weight data
  #
  # Inputs:
  #  - date.start: First date in range to pull
  #  - date.end:   Last date in range to pull
  #  - token:      OAuth2.0 access token

  what <- 'weight'
  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, add_headers("Authorization"= token))

  nutrition.df <- as.data.frame(do.call(rbind, httr::content(request)[[1]]))

  # Weight data also includes some extra stuff we don't need.
  nutrition.df <- subset(nutrition.df, select=c(date, bmi, weight))

  names(nutrition.df)[names(nutrition.df) == 'date'] <- 'time'
  nutrition.df$time <- as.character(nutrition.df$time, is.factor=FALSE)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

get_nutrition <- function(date.start, date.end, token){
  # Fetch Fitbit nutrition data
  #
  # Inputs:
  #  - date.start: First date in range to pull
  #  - date.end:   Last date in range to pull
  #  - token:      OAuth2.0 access token

  what <- 'nutrition'

  # Need to fetch each day individually so make a list of dates to pull
  dates = seq(from=as.Date(date.start), to=as.Date(date.end), by=1)

  for (date in as.character(as.Date(dates))) {
    url <- paste(API_URL, RESOURCES[[what]],'/date/', date, '.json', sep='')
    request <- httr::GET(url, add_headers("Authorization"= token))

    # First time through loop, create nutrition.df
    if (!exists('nutrition.df')) {
      nutrition.df <- as.data.frame(httr::content(request)$summary)
      nutrition.df$time <- date
      cat(paste('Make row', date, '\n'))
    } else { # Append to nutrition.df
      nutrition.row <- as.data.frame(httr::content(request)$summary)
      nutrition.row$time <- date

      cat(paste('Bind row', date, '\n'))
      nutrition.df <- rbind(nutrition.df, nutrition.row)
    }
  }
  #nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}
