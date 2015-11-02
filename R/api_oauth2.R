#------------------------------------------------------------------------------
# api_oauth2.R
#
# Functions for authenticating with Fitbit
#------------------------------------------------------------------------------

auth.file <- paste(AUTH.LOCATION, '.OAuth', sep=.Platform$file.sep)
API_URL <- 'https://api.fitbit.com/1/user/-/'

api_auth <- function(auth.file=auth.file){
  clientID <- readline("Fitbit API OAuth 2.0 client ID: ")

  # construct string to put in GET request for authentication
  oauthString <-
    paste0("https://www.fitbit.com/oauth2/authorize?response_type=token",
           "&client_id=",
           clientID,
           "&redirect_uri=http%3A%2F%2Flocalhost%3A1410",
           "&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight",
           "&expires_in=604800")

  cat('Paste the link below into a browser window and accept.\n\n')
  cat(oauthString)
  cat('\n\nCopy the long string following "accesstoken=" in the the resulting return URL and paste it below.\n\n')
  token <- readline("Access Token: ")

  write(token, auth.file)

  return(token)
}

#' Check for the existence of an oauth token
#'
#' @param auth.file file path of stored token
#'
#' @export
auth_configured <- function(auth.file=auth.file) {
  if (exists(auth.file)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Get stored token from file
#'
#' @param auth.file file path of stored token
#'
#' @export
read_token <- function(auth.file=auth.file) {
  if (exists(auth.file)) {
    token <- readChar(auth.file, file.info(fileName)$size)
  } else {
    token <- api_auth(auth.file)
  }

  return(paste('Bearer', token, sep=' '))
}
