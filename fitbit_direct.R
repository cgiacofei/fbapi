library("fitbitScraper")

source('settings.R')

cookie <- fitbitScraper::login(
  email=fb.email,
  password=fb.password,
  rememberMe=TRUE
)

LOGGABLES <- c("steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake",
  "getTimeInHeartRateZonesPerDay", "getRestingHeartRateData")

end.date <- as.character(as.Date(Sys.Date()) - 1)

if (file.exists('data.csv')){
  file.Df <- read.csv('data.csv')
  
  start.date <- as.character(max(as.Date(file.Df$time)) + 1)

} else {
  start.date <- "2015-10-09"
}

if (start.date >= end.date){

  cat('Data already current, come back tomorrow.')

} else {
  # Loop through available daily data
  for (loggable in LOGGABLES) {
    if (exists("total.data")) {
      
      loop.data <- as.data.frame(fitbitScraper::get_daily_data(
        cookie,
        loggable,
        start_date="2015-10-09",
        end_date=as.character(Sys.Date())
      ))
      loop.data$time <- as.character(as.Date(loop.data$time))
      total.data <- merge(total.data, loop.data,by="time")
      
    } else {
      
      total.data <- as.data.frame(fitbitScraper::get_daily_data(
        cookie,
        loggable,
        start_date="2015-10-09",
        end_date=as.character(Sys.Date())
      ))
      total.data$time <- as.character(as.Date(total.data$time))
    }
  }
  
  
  
  # Gather heart-rate and calories
  date.sequence <- as.character(seq(as.Date(start.date), as.Date(end.date), by = "day"))
  
  calories <- data.frame(time=character(0), calories.burned=numeric(0))
  
  for (date in date.sequence){
    cals <- fitbitScraper::get_intraday_data(
      cookie,
      what="calories-burned",
      date
    )
    
    total.cals <- sum(cals$'calories-burned')
    cat(paste(date, total.cals, '\n', sep=' '))
    calories <- rbind(calories, c(date, total.cals))
  }
  
  fitbitScraper::get_intraday_data()
  # Gather Weight measurements
  weight.data <- fitbitScraper::get_weight_data(
    cookie,
    start_date="2015-10-09",
    end_date=as.character(Sys.Date())
  )
  
  
  weight.data$time <- as.character(as.Date(weight.data$time))
  
  total.data <- merge(total.data, weight.data,by="time", all.x=TRUE)
  
  
  
  write.csv(total.data, file="data.csv")

}

