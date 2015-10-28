
get.oauth.string <- function(clientID) {
  # construct string to put in GET request for authentication
  oauthString <- 
    paste0("https://www.fitbit.com/oauth2/authorize?response_type=token",
           "&client_id=",
           clientID,
           "&redirect_uri=http%3A%2F%2Flocalhost%3A1410",
           "&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight",
           "&expires_in=604800")
  # print out the generated string
  return(oauthString)
}


get.data <- function(token, getString) {
  # Query fitbit API and return json object of a daily food log
  #
  # Returns:
  #  - foods:   list of detailed foods for the day
  #  - goals:   list of goals for the day
  #  - summary: nutrient summary for the day
  
  accessToken <- paste('Bearer', token, sep=' ')
  
  # make the request
  request <- GET(getString, add_headers("Authorization"=accessToken))
  
  return(content(request))
}