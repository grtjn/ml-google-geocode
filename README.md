# ml-google-geocode

MarkLogic XQuery library for calling Google's geocoding endpoint

Note: Google allows making about 2500 geocoding calls per day for free, and max 10 per second. Consider getting an API key for better Quota management:
  https://developers.google.com/maps/documentation/geocoding/get-api-key
  
Note: If using this code from inside an MLCP transform, make sure to pace it down to single thread with `--nr_threads 1 --transaction_size 1 --batch_size 1`.

IMPORTANT: Make sure you reviewed the usage Policies from Google about using the Encoding API. It is available at: 

  https://developers.google.com/maps/documentation/geocoding/policies

Most importantly it states:

> The Google Maps Geocoding API may only be used in conjunction with displaying results on a Google map. It is prohibited to use Google Maps Geocoding API data without displaying a Google map.

## Install

Installation depends on the [MarkLogic Package Manager](https://github.com/joemfb/mlpm):

```
$ mlpm install ml-google-geocode --save
$ mlpm deploy
```

## Usage

```xquery
xquery version "1.0-ml";

import module namespace geo = "http://marklogic.com/geocoding" at "/ext/mlpm_modules/ml-google-geocode/geocoding.xqy";

geo:geocode("Central Station, Amsterdam, The Netherlands", "myapikeylksajhfkasdjfhksdjahkl")/result[1]/geometry[1]/location[1],

geo:persistCache()
```
