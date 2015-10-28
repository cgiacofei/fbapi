# a simple Oauth connection with Fitbit API
library(httr)

source('R/settings.R')
source('R/functions.R')
source('R/dev.R')

api_auth <- function(key, secret){
  # Generate authentication token for fitbit API
  #
  # Inputs:
  #  - key:   Fitbit API consumer key
  #  - secret: Fitbit API consumer secret
  #
  # Returns: Token for interacting with API

  token_url = "https://api.fitbit.com/oauth/request_token"
  access_url = "https://api.fitbit.com/oauth/access_token"
  auth_url = "https://www.fitbit.com/oauth/authorize"
    
  fbr = oauth_app('data_access', key, secret)
  fitbit = oauth_endpoint(token_url, auth_url, access_url)
  token = oauth1.0_token(fitbit,fbr)
  sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)
  
  return(sig)
}

api_get <- function(url, token){
  # Get data from fitbit API
  #
  # Inputs:
  #  - url:   API url to grab data ie. 'activities/heart/date/2015-10-09/2015-10-26'
  #  - token: Signature token returned from api_auth()
  #
  # Returns: Content of API reponse

  API_URL <- 'https://api.fitbit.com/1/user/-/'
  resp = GET(paste(API_URL, url,'.json'), token)
  
  return(content(resp))
}
