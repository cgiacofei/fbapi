source('R/dev.R')
source('R/functions.R')
pkgTest('httr') # load package for http communication
pkgTest('plyr')
pkgTest('reshape2')

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

resource_get <- function(what, date.start, date.end, token){
  API_URL <- 'https://api.fitbit.com/1/user/-/'
  
  dateRange <- paste(date.start, date.end, sep='/')
  
  
  
  if (what == 'nutrition'){
    dates = seq(from=as.Date(date.start), to=as.Date(date.end), by=1)
    for (date in as.character(as.Date(dates))) {
      url <- paste(API_URL, RESOURCES[[what]],'/date/', date, '.json', sep='')
      request <- GET(url, add_headers("Authorization"= token))

      if (!exists('fb.df')) {
        fb.df <- as.data.frame(content(request)$summary)
        fb.df$time <- date
      } else {
        nutrition.row <- as.data.frame(content(request)$summary)
        nutrition.row$time <- date
        
        fb.df <- rbind(fb.df, nutrition.row)
      }
    }

  } else {
    url <- paste(API_URL, RESOURCES[[what]],'/date/', dateRange, '.json', sep='')
    # make the request
    request <- GET(url, add_headers("Authorization"= token))
    
    if (what == 'heartRate'){
      
      data <- jsonlite::fromJSON(jsonlite::toJSON(content(request)))
      fb.df <- data$`activities-heart`[1]
      fb.df$RHR <- data[[1]]$value$restingHeartRate
      names(fb.df) <- c('time', what)
      fb.df$time <- as.character(fb.df$time, is.factor=FALSE)
      
    } else if (what == 'weight') {
      
      fb.df <- as.data.frame(do.call(rbind, content(request)[[1]]))
      fb.df <- subset(fb.df, select=c(date, bmi, weight))
      names(fb.df)[names(fb.df) == 'date'] <- 'time'
      fb.df$time <- as.character(fb.df$time, is.factor=FALSE)
      
    } else {
      
      fb.df <- as.data.frame(do.call(rbind, content(request)[[1]]))
      fb.df$dateTime <- as.character(fb.df$dateTime, is.factor=FALSE)
      names(fb.df) <- c('time', what)
      
    }
    fb.df[2:NCOL(fb.df)] <-as.numeric(unlist(fb.df[2:NCOL(fb.df)]))
  }

  
  return(fb.df)
}

api_get <- function(date.start, date.end, token){
  # Scrape data from fitbit website
  #
  # Inputs:
  #  - date.start: Start of date range
  #  - date.end:   End of date range
  #  - token:      Authentication token from fitbit_auth()

  LOGGABLES <- c(
    'calorieOut',
    'activityCalories',
    'steps',
    'distance',
    'floors',
    'minutesSedentary',
    'minutesLightly',
    'minutesFairly',
    'minutesVery',
    'heartRate',
    'weight',
    'nutrition'
  )

  for (loggable in LOGGABLES) {
    cat(paste('Fetching', loggable, '.....\n'))
    if (exists('total.data')) {

      loop.data <- resource_get(loggable, date.start, date.end, token)
      total.data <- merge(total.data, loop.data,by="time", all.x=TRUE)
      cat(paste(loggable, 'Data merged.\n'))

    } else {

      total.data <- resource_get(loggable, date.start, date.end, token)
      cat('New dataset started.\n')
    }
  }

  return(total.data)
}
