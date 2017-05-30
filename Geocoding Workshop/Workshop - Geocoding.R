#############################################

# RDSTK Geocoding Basics 

# Create Dummy Data Frame 
addresses<- (c("606 W 122nd St, New York, NY 10027", "1600 Pennsylvania Ave NW, Washington, DC 20500"))
IDs<- c("1","2")
sample_addresses= data.frame(addresses, IDs) 
sample_addresses$Longitude<-NA
sample_addresses$Latitude<-NA
sample_addresses$addresses<-as.character(sample_addresses$addresses)
View(sample_addresses)

# RDSTK: street2coordinates function
# provides data on one address at a time

i<-sample_addresses$address[1]
coords<-street2coordinates(i)
str(coords)
coords$latitude
coords$longitude

# Geocoding Multiple Addresses: Looping
sample_addresses$Longitude<-NA
sample_addresses$Latitude<-NA

for (i in 1:nrow(sample_addresses)){
  temp.address<-sample_addresses$address[i]
  coords<-street2coordinates(temp.address)
  sample_addresses$Latitude[i]<- coords$latitude
  sample_addresses$Longitude[i]<- coords$longitude
  print(i)
}

View(sample_addresses)

###########################################################
#Validation Checks: 

# Do a quick check on addresses: http://www.mapcoordinates.net/en
# or throw the lat,long into the search bar on google maps


########################################################
# ACTUAL Geocoding - Using Project Data 
# Start Here for Actual Geocoding

### Exercise - NEA data File - Setting up File 

#Load Data File
setwd("~/Desktop/NEA data/Data/Updated NEA Data")
NEA_Subgrants_16<-read.csv("NEA State Subgrants 2016.csv", stringsAsFactors = F)
str(NEA_Subgrants_16)

NEA_Subgrants_16$CoLatitude<-NA
NEA_Subgrants_16$CoLongitude<-NA

#pad zipcodes to five digits

NEA_Subgrants_16$applzip
NEA_Subgrants_16$applzip_Padded<- str_pad(NEA_Subgrants_16$applzip,5,pad="0")

#create full address 
NEA_Subgrants_16$Full_Address<-paste(NEA_Subgrants_16$appladdress, ",",
                                     NEA_Subgrants_16$applcity, ",",
                                     NEA_Subgrants_16$applstate, ",",
                                     NEA_Subgrants_16$applzip_Padded)

#Removes Unicode Problems, Quotation Marks a Problem in JSON
# ADD ANY ADDITIONAL EDITS HERE
NEA_Subgrants_16$Full_Address <- gsub("[^[:graph:]]", " ", NEA_Subgrants_16$Full_Address)
NEA_Subgrants_16$Full_Address <- gsub("\"", " ", NEA_Subgrants_16$Full_Address)


#Taking Unique Addresses
all.miss.add <- unique(NEA_Subgrants_16$Full_Address)
length(all.miss.add)

#Create chunks of Data with 100 at a time
add.chunks <- makeChunkIndex(all.miss.add, group.size = 100)

#Creates Output List of Groups of Hundred Addresses 
add.coded <- as.list(rep(NA, length(add.chunks)))

#loop applying function of geocoding for Chunks
# for elements of the list that are NA in Output List

for(ii in which(is.na(add.coded))) {
  print(ii)
  add.coded[[ii]] <- try(address2LatLon(all.miss.add[add.chunks[[ii]]]))
  if(class(add.coded[[ii]])=="try-error") {
    break()
  } 
}

## TROUBLESHOOTING CODE: 
#all.miss.add[201:300]
# address2LatLon(all.miss.add[add.chunks[[2]]])
#add.coded[[ii]]  <- NA


# CLEAN DATA: 
# do.call applies rbind to the list to make a matrix
add.coded <- do.call(rbind, add.coded)

#takes list and turns into a vector
add.coded$lat <- unlist(add.coded$lat)
add.coded$lon<- unlist(add.coded$lon)


### Match Lat/Long back to main files 
NEA_Subgrants_16$CoLatitude <- add.coded$lat[match(NEA_Subgrants_16$Full_Address, 
                                                   add.coded$address)]

NEA_Subgrants_16$CoLongitude <- add.coded$lon[match(NEA_Subgrants_16$Full_Address,
                                                    add.coded$address)]

## Add Data Coding Source (Optional)

NEA_Subgrants_16$GeocodeSrc <- NA
NEA_Subgrants_16$GeocodeSrc[!is.na(NEA_Subgrants_16$CoLatitude)] <- "DSTK"

## View Data
View(NEA_Subgrants_16[sample(1:nrow(NEA_Subgrants_16), 10),])

table(is.na(NEA_Subgrants_16$CoLatitude))
View(NEA_Subgrants_16[which(is.na(NEA_Subgrants_16$CoLatitude)), ])

#when you're satisfied with the file: 
#write.csv(NEA_Subgrants_16, "NEA_Subgrants_16_geocodes.csv")




