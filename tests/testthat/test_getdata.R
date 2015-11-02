
RESOURCES <- c(
  steps='step.json',
  heartRate='hr.json',
  weight='wt.json',
  nutrition='nutrition.json'
)

# Create dummy function called pull data that returns stored objects instead
# of polling the Fitbit API.
pull_data <- function(what, date.start, date.end) {

  return(readRDS(file=RESOURCES[[what]]))

}

context('Test Data Parsing')

test_that('activity data is correctly parsed', {
  dummy <- get_activity('steps', NULL, NULL)
  expect_true(exists('dummy'))
})
