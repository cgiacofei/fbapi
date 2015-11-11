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

#' Recursively build matrix of dates with 31 day ranges.
#'
#' Fitbit API only allows for pullig 31 days of data per call for some items.
#' This function takes a date range and divides it into multiple ranges no more
#' than 31 days in length.
#'
#' @param date.start First date in range to pull
#' @param date.end Last date in range to pull
#' @param dlist
#'
#' @return matrix of dates
#'
#' @export
range_list <- function(date.start, date.end, dlist=NULL) {
  date.start <- as.Date(date.start)
  date.end <- as.Date(date.end)

  if ((date.end - date.start) > 31) {
    date.final <- date.end
    date.end <- date.start + 30
    dlist <- rbind(dlist, c(as.character(date.start), as.character(date.end)))
    date.start <- date.end + 1

    dlist <- range_list(date.start, date.final, dlist)
  } else {
    dlist <- rbind(dlist, c(as.character(date.start), as.character(date.end)))
  }

  return(dlist)
}

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

  return(jsonlite::toJSON(httr::content(request)))
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

  content <- jsonlite::fromJSON(pull_data(what, date.start, date.end))

  nutrition.df <- as.data.frame(content[[1]])

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

  content <- jsonlite::fromJSON(pull_data('heartRate', date.start, date.end))

  # Extract resting heart rate.
  # Eventually want heart rate zone data but that will take some
  # additional processing.
  nutrition.df <- content$`activities-heart`[1]
  nutrition.df$RHR <- content[[1]]$value$restingHeartRate

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
  dates <- range_list(date.start, date.end)

  weight.Df <- NULL

  for (i in c(1:NROW(dates))) {
    date.start <- dates[i,1]
    date.end <- dates[i,2]
    cat(paste('Pulling range: ', date.start, '-', date.end, '\n', sep=''))

    content <- jsonlite::fromJSON(pull_data('weight', date.start, date.end))

    weight.Df <- rbind(weight.Df, content$weight)

  }

  # Weight data also includes some extra stuff we don't need.
  myCols <- c('date', 'bmi', 'weight')
  colNums <- match(myCols,names(weight.Df))
  weight.Df <- dplyr::select(weight.Df, colNums)

  names(weight.Df)[names(weight.Df) == 'date'] <- 'time'
  weight.Df$time <- as.character(weight.Df$time, is.factor=FALSE)

  weight.Df[2:NCOL(weight.Df)] <-as.numeric(unlist(weight.Df[2:NCOL(weight.Df)]))

  return(weight.Df)
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

  # Need to fetch each day individually so make a list of dates to pull
  dates = seq(from=as.Date(date.start), to=as.Date(date.end), by=1)
  for (date in as.character(as.Date(dates))) {
    content <- jsonlite::fromJSON(pull_data('nutrition', date, NULL))

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
