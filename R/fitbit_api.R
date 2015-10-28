# a simple Oauth2.0 connection with Fitbit API
library(httr)

source('settings.R')
source('functions.R')
source('dev.R')

API_URL <- 'https://api.fitbit.com/1/user/-/'

token_url = "https://api.fitbit.com/oauth/request_token"
access_url = "https://api.fitbit.com/oauth/access_token"
auth_url = "https://www.fitbit.com/oauth/authorize"

key <- '31602c6029b39e65bd6ee6ed18499bf0'
secret <- '724a62b928a0ed884bf5031f133009fd'

fbr = oauth_app('data_access',key,secret)
fitbit = oauth_endpoint(token_url,auth_url,access_url)
token = oauth1.0_token(fitbit,fbr)
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

resp = GET(paste(API_URL,'activities/heart/date/2015-10-09/2015-10-26.json'), sig)
content(resp)

gs <- paste(API_URL,'activities/heart/date/2015-10-09/2015-10-26.json')
heart.rate <- content(GET(gs,gtoken))

gs <- paste(API_URL,'body/log/weight/2015-10-09/2015-10-26.json')
weight <- content(GET(gs,gtoken))
weight
test <- NULL
for (entry in weight$weight) {
  test <- rbind(test, entry)
}
rownames(test) <- NULL
