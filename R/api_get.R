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

#' Fetch Fitbit data
#'
#' Pulls data from the speicified date range.  Nutrition data is pulled only
#' one day at a time based on the given date.start value.
#'
#' @param what Resource name to pull
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#'
#' @return dataframe
#'
#' @export
get <- function(what, date.start, date.end){
  token <- read_token()
  
  if (what == 'nutrition') {
    dateRange <- date.start
  } else {
    dateRange <- paste(date.start, date.end, sep='/')
  }

  url <- paste(API_URL, what, '/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, httr::add_headers("Authorization"= token))

  data <- jsonlite::toJSON(httr::content(request))

  if (what == 'heartRate') {
    pretty.Df <- parse_heart(data)

  } else if (what == 'weight') {
    pretty.Df <- parse_weight(data)

  } else if (what == 'nutrition') {
    pretty.Df <- parse_nutrition(data, dateRange)

  } else {
    pretty.Df <- parse_activity(data)

  }
  
  return(pretty.Df)
}

#' Parse Fitbit activity time series data
#'
#' @param data API return content parsed from JSON.
#'
#' @return dataframe
#'
#' @export
parse_activity <- function(data)

  activity.df <- as.data.frame(data[[1]])
  activity.df$dateTime <- as.character(activity.df$dateTime, is.factor=FALSE)

  names(nutrition.df) <- c('time', what)

  activity.df[2:NCOL(activity.df)] <-as.numeric(unlist(activity.df[2:NCOL(activity.df)]))

  return(activity.df)
}

#' Parse Fitbit heart rate data
#'
#' @param data API return content parsed from JSON.
#'
#' @return dataframe
#'
#' @export
parse_heart <- function(data){

  # Extract resting heart rate.
  # Eventually want heart rate zone data but that will take some
  # additional processing.
  heart.df <- data$`activities-heart`[1]
  heart.df$RHR <- content[[1]]$value$restingHeartRate

  names(heart.df) <- c('time', 'heartRate')
  heart.df$time <- as.character(heart.df$time, is.factor=FALSE)

  heart.df[2:NCOL(heart.df)] <-as.numeric(unlist(heart.df[2:NCOL(heart.df)]))

  return(nutrition.df)
}

#' Parse Fitbit weight data
#'
#' @param data API return content parsed from JSON.
#'
#' @return dataframe
#'
#' @export
parse_weight <- function(data){

  weight.df <- as.data.frame(data$weight)

  # Weight data also includes some extra stuff we don't need.
  myCols <- c('date', 'bmi', 'weight')
  colNums <- match(myCols,names(weight.df))
  weight.df <- dplyr::select(weight.df, colNums)

  names(weight.df)[names(weight.df) == 'date'] <- 'time'
  weight.df$time <- as.character(weight.df$time, is.factor=FALSE)

  weight.df[2:NCOL(weight.df)] <-as.numeric(unlist(weight.df[2:NCOL(weight.df)]))

  return(weight.df)
}

#' Fetch Fitbit nutrition data
#'
#' @param data API return content parsed from JSON.
#' @param date date being parsed.
#'
#' @return dataframe
#'
#' @export
parse_nutrition <- function(data, date){

  nutrition.df <- as.data.frame(content$summary)
  nutrition.df$time <- date

  #nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}
