
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
  expect_that(nrow(get_activity('steps', NULL, NULL)), equals(8))
  expect_that(ncol(get_activity('steps', NULL, NULL)), equals(2))
  expect_that(mean(get_activity('steps', NULL, NULL)$value), equals(7316.5))
})
