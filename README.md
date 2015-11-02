# Fitbit Analysis

## Description
Pulls data from the fitbit website for analysis. Currently able to pull:
 * steps
 * distance
 * floors
 * active minutes (sedentary/light/fair/very)
 * calories burned
 * calories consumed
 * resting heartrate
 * weight
 * daily nutrition summary

The file read.R is used for reading fitbit data from the web. Data is read using the Fitbit API and OAuth 2.0.

### Authentication
Authentication is performed using method found here: http://blog.numbersinlife.com/2015/09/silly-oauth2-connect-to-fitbit-api-from.html

1. Authentication triggered automatically if no AccessToken has been previously stored.
2. Enter OAuth 2.0 clientID from Fitbit API app manager.
3. Copy the genereated URL string to browser as the address.
4. Confirm the requested permissions.
5. The browser will say the requested page is not available, but there will be an URL in the address field (the URL will start with http://localhost:1410/). Copy and paste the returned url somewhere.
6. Find "access_token=" in it and copy the long string after the equals sign.
7. Paste at the prompt.
8. Token will be stored in a file in the home directory (~/.fbapi/.OAuth)

## TODO
- [ ] Sleep data import
  - [ ] Parsing json data
  - [ ] Summarize by day
