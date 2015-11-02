#------------------------------------------------------------------------------
# api_oauth2.R
#
# Functions for authenticating with Fitbit
#------------------------------------------------------------------------------

if (.Platform$OS.type=='windows') {
  os.sep <- '\\'

} else {
  os.sep <- '/'
}

AUTH.LOCATION <- paste(Sys.getenv("HOME"), '.fbapi', sep=os.sep)
TOKEN.FILE <- paste(AUTH.LOCATION, '.OAuth', sep=os.sep)
API_URL <- 'https://api.fitbit.com/1/user/-/'

#' Interactively get authorization token from Fitbit
#'
#'
#' @export
api_auth <- function(){
  cat('Fitbit API OAuth 2.0 client ID: ')
  clientID <- readLines(con='stdin', 1)

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
  cat('Access Token: ')
  token <- readLines(con='stdin', 1)
  write(token, TOKEN.FILE)

  return(token)
}

#' Check for the existence of an oauth token
#'
#'
#' @export
auth_configured <- function() {
  if (exists(TOKEN.FILE)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Get stored token from file
#'
#'
#' @export
read_token <- function() {
  if (file.exists(TOKEN.FILE)) {
    token <- readChar(TOKEN.FILE, file.info(TOKEN.FILE)$size)
  } else {
    token <- api_auth()
  }

  return(paste('Bearer', token, sep=' '))
}
