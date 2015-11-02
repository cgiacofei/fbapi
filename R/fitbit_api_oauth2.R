#------------------------------------------------------------------------------
# fitbit_api_oauth2.R
#
# Functions for authenticating with Fitbit and parsing data
#------------------------------------------------------------------------------

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

#' Print OAuth 2.0 URL
#'
#' Construct string to put in GET request for authentication
#'
#' @param clientID OAuth 2.0 client ID from Fitbit App Manager
#'
#' @return None
#'
#' @examples
#' api_auth('23RRV4')
#'
#' @export
api_auth <- function(clientID){
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

#' Fetch Fitbit activity time series data
#'
#' @param what Resource name to pull
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#' @param token OAuth2.0 access token
#'
#' @return dataframe
#'
#' @export
get_activity <- function(what, date.start, date.end, token){

  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, httr::add_headers("Authorization"= token))

  nutrition.df <- as.data.frame(do.call(rbind, httr::content(request)[[1]]))
  nutrition.df$dateTime <- as.character(nutrition.df$dateTime, is.factor=FALSE)

  names(nutrition.df) <- c('time', what)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

#' Fetch Fitbit heart rate data
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#' @param token OAuth2.0 access token
#'
#' @return dataframe
#'
#' @export
get_heart <- function(date.start, date.end, token){

  what <- 'heartRate'
  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, httr::add_headers("Authorization"= token))

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

#' Fetch Fitbit weight data
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#' @param token OAuth2.0 access token
#'
#' @return dataframe
#'
#' @export
get_weight <- function(date.start, date.end, token){
  what <- 'weight'
  dateRange <- paste(date.start, date.end, sep='/')

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, httr::add_headers("Authorization"= token))

  nutrition.df <- as.data.frame(do.call(rbind, httr::content(request)[[1]]))

  # Weight data also includes some extra stuff we don't need.
  myCols <- c('date', 'bmi', 'weight')
  colNums <- match(myCols,names(mtcars))
  nutrition.df <- dplyr::select(nutrition.df, colNums)

  names(nutrition.df)[names(nutrition.df) == 'date'] <- 'time'
  nutrition.df$time <- as.character(nutrition.df$time, is.factor=FALSE)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

#' Fetch Fitbit nutrition data
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#' @param token OAuth2.0 access token
#'
#' @return dataframe
#'
#' @export
get_nutrition <- function(date.start, date.end, token){
  what <- 'nutrition'

  # Need to fetch each day individually so make a list of dates to pull
  dates = seq(from=as.Date(date.start), to=as.Date(date.end), by=1)

  for (date in as.character(as.Date(dates))) {
    url <- paste(API_URL, RESOURCES[[what]],'/date/', date, '.json', sep='')
    request <- httr::GET(url, httr::add_headers("Authorization"= token))

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
