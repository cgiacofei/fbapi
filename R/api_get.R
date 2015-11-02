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
#' @param what Resource name to pull
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#'
#' @return dataframe
#'
#' @export
pull_data <- function(what, date.start, date.end){

  token <- read_token()

    # Need to fetch each day individually so make a list of dates to pull
  if (is.null(date.end )) {
    dateRange = date.start
  } else {
    dateRange <- paste(date.start, date.end, sep='/')
  }

  url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
  request <- httr::GET(url, httr::add_headers("Authorization"= token))

  return(httr::content(request))
}

#' Fetch Fitbit activity time series data
#'
#' @param what Resource name to pull
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#'
#' @return dataframe
#'
#' @export
get_activity <- function(what, date.start, date.end){

  content <- pull_data(what, date.start, date.end)

  nutrition.df <- as.data.frame(do.call(rbind, content[[1]]))
  nutrition.df$dateTime <- as.character(nutrition.df$dateTime, is.factor=FALSE)

  names(nutrition.df) <- c('time', what)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

#' Fetch Fitbit heart rate data
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#'
#' @return dataframe
#'
#' @export
get_heart <- function(date.start, date.end){

  content <- pull_data('heartRate', date.start, date.end)

  # This seems hacky but it works.
  data <- jsonlite::fromJSON(jsonlite::toJSON(content))

  # Extract resting heart rate.
  # Eventually want heart rate zone data but that will take some
  # additional processing.
  nutrition.df <- data$`activities-heart`[1]
  nutrition.df$RHR <- data[[1]]$value$restingHeartRate

  names(nutrition.df) <- c('time', 'heartRate')
  nutrition.df$time <- as.character(nutrition.df$time, is.factor=FALSE)

  nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}

#' Fetch Fitbit weight data
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#'
#' @return dataframe
#'
#' @export
get_weight <- function(date.start, date.end){

  content <- pull_data('weight', date.start, date.end)

  nutrition.df <- as.data.frame(do.call(rbind, content[[1]]))

  # Weight data also includes some extra stuff we don't need.
  myCols <- c('date', 'bmi', 'weight')
  colNums <- match(myCols,names(nutrition.df))
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
#'
#' @return dataframe
#'
#' @export
get_nutrition <- function(date.start, date.end){
  what <- 'nutrition'

  # Need to fetch each day individually so make a list of dates to pull
  dates = seq(from=as.Date(date.start), to=as.Date(date.end), by=1)
  for (date in as.character(as.Date(dates))) {
    content <- pull_data('nutrition', date, NULL)

    # First time through loop, create nutrition.df
    if (!exists('nutrition.df')) {
      nutrition.df <- as.data.frame(content$summary)
      nutrition.df$time <- date
      cat(paste('Make row', date, '\n'))
    } else { # Append to nutrition.df
      nutrition.row <- as.data.frame(content$summary)
      nutrition.row$time <- date

      cat(paste('Bind row', date, '\n'))
      nutrition.df <- rbind(nutrition.df, nutrition.row)
    }
  }
  #nutrition.df[2:NCOL(nutrition.df)] <-as.numeric(unlist(nutrition.df[2:NCOL(nutrition.df)]))

  return(nutrition.df)
}
