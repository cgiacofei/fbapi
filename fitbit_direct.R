library("fitbitScraper")

source('secrets.R')

print(fitbit.email)
print(fitbit.password)

fitbitScraper::login(
  email=fitbit.email,
  password=fitbit.password,
  rememberMe=TRUE
)
