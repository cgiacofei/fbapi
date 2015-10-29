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
Needs a file named settings.R containing:  
**clientID:** OAuth2.0 client ID  
**token:** Access token generated using authentication instructions below


Authentication is performed using method found here: http://blog.numbersinlife.com/2015/09/silly-oauth2-connect-to-fitbit-api-from.html

1. From the file *fitbit_api_oauth2.R* the funtion *api_auth(clientID)* is run, with clientID being the OAuth2.0 client ID supplied by the fitbit API app manager.
2. Copy the genereated URL string to browser as the address.
3. Confirm the requested permissions.
4. The browser will say the requested page is not available, but there will be an URL in the address field (the URL will start with http://localhost:1410/). Copy and paste the returned url somewhere.
5. Find "access_token=" in it and copy the long string after the equals sign.
6. Add word "Bearer" in front. 
7. Save to a variable (called **token** in read.R) to use later.

```Rscript  
token <- 'Bearer <long string from URL>'
```

## TODO
- [ ] Sleep data import
  - [ ] Parsing json data
  - [ ] Summarize by day
- [ ] FitNotes data parsing
