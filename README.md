# Fitbit Analysis

## Description
Pulls data from the fitbit website for analysis. Currently able to pull:
 * steps
 * distance
 * floors
 * active minutes
 * calories burned
 * time in heartrate zones
 * resting heartrate
 * weight

Needs a file named settings.R containing:  
**For web scraping**
```
fitbit.email <- 'FITBIT_EMAIL'
fitbit.password <- 'FITBIT_PASSWORD'
```  
**For API Access**
```
api.key <- 'API_CONSUMER_KEY'
api.secret <- 'API_CONSUMER_SECRET'
```

The file read.R is used for reading fitbit data from the web. Currently it is setup for scraping the webpage directly.

## TODO
 1. Get calories in
 2. 
