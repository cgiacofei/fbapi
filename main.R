# a simple Oauth2.0 connection with Fitbit API
install.packages("httr") # install if not installed
library("httr") # load package for http communication

# set client ID - REPLACE WITH YOURS INSIDE THE QUOTES! 
clientID = "229RKV"

# construct string to put in GET request for authentication
oauthString <- 
  paste0("https://www.fitbit.com/oauth2/authorize?response_type=token",
         "&client_id=",
         clientID,
         "&redirect_uri=http%3A%2F%2Flocalhost%3A1410",
         "&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight",
         "&expires_in=604800")
# print out the generated string
print(oauthString)

# copy above URL string to browser as the address
# a page should open listing the permissions you requested
# confirm requested permissions
# the browser will say the requested page is not available (or something to that effect)
# but there will be an URL in the address field
# (the URL will start with http://localhost:1410/)
# copy and paste the returned url somewhere
# find "access_token=" in it and copy the long string after the equals sign
# add word "Bearer" in front
# save to a variable to use later
# see example bellow
accessToken <- "Bearer PASTE_HERE"
  
# use the token in the API calls like in the example below
# but replace the "getString" variable with your API call string
# you can construct the string according to instructions (for heart rate)
# https://dev.fitbit.com/docs/heart-rate/
# this is for today's heart rate data in json
getString <- "https://api.fitbit.com/1/user/-/activities/heart/date/today/1d.json"
# make the request
request <- GET(getString,
               add_headers("Authorization"= accessToken))
# look at returned contents
content(request) 
