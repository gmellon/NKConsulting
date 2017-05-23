### Install Packages: Do this once
install.packages("httr")
install.packages("stringr")
install.packages("RDSTK")
install.packages("rjson")
install.packages("RCurl")
install.packages("bitops")
install.packages("RDSTK")
install.packages("sp")
install.packages("tigris")

### Load Packages: Do this every time you run the geocoding 
## Run all of the following codes

library(httr)
library(stringr)
library(plyr)
library(rjson)
library(RCurl)
library(bitops)
library(RDSTK)
library(sp)
library(tigris)

## Run the following Code to load relevant geocoding functions

#data frame function (generic)
dtf <- function(..., StAsFa= FALSE) {
  data.frame(..., stringsAsFactors = StAsFa)
}

# prevents time out of API call (Below)
#function of vector, group size to run groups


makeChunkIndex <- function(x, group.size) {
  chunks <- split(1:length(x), ceiling(seq_along(1:length(x)) / group.size) )
}

# (Below): allows you to pass a vector of addresses, rather than one
# server will give geocodes in bulk, rather than individually
# Most of run time defined by time required to run one 

address2LatLon <- function(addresses) {
  require(httr)
  #creates a json object from vector
  addresses <- paste(addresses, collapse = "\",\"")
  addresses <- paste0("[\"", addresses, "\"]")
  # post json object to DSTK API 
  output <- POST('http://www.datasciencetoolkit.org/street2coordinates',
                 body = addresses, encode = 'json')
  # turns json object to R List
  output <- content(output, "parsed")
  # function to extract lat/long
  getLatLon <- function(x) {
    lat <- x["latitude"]
    lon <- x["longitude"]
    lon[is.null(lon)] <- NA
    lat[is.null(lat)] <- NA
    c(lat,lon)
  }
  
  #creates list with lat/long and transposes
  output <- t(sapply(output, getLatLon))
  #adds column names
  colnames(output) <- c("lat", "lon")
  #returns data frame, and adds address names as columns
  output <- dtf(address = rownames(output), output)
  return(output)
}
