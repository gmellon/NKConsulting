## File for linking geocoded data to district boundaries

#install these packages if you don't have them
require(rgdal)
require(sp)
require(maps)
require(tigris)

NEA_Subgrants_16$AFFGEOID<-NA

#Uses the tigris package to pull in the congressional districts
CD <- congressional_districts(cb = TRUE)

#converts the Latitude and Lontitude columns into a Geospatial Data Frame
complete_spatial<- NEA_Subgrants_16[!is.na(NEA_Subgrants_16$CoLatitude), ]
nrow(complete_spatial)
coordinates(complete_spatial) <- c("CoLongitude", "CoLatitude")

#Sets Proj4Strings of geos to that of districts
proj4string(complete_spatial)<-proj4string(CD)

#determines which districts contain geos

inside.district <- !is.na(over(complete_spatial, as(CD, "SpatialPolygons")))
#Checks the fraction of geos inside a district
mean(inside.district)

#Takes the values for District and adds them to your geos data
complete_spatial$AFFGEOID <- over(complete_spatial,CD)$AFFGEOID

head(complete_spatial$AFFGEOID)

#match back to main file 

NEA_Subgrants_16$AFFGEOID<-NA
NEA_Subgrants_16$AFFGEOID[is.na(NEA_Subgrants_16$AFFGEOID)] <- complete_spatial$AFFGEOID[
  match(NEA_Subgrants_16$Full_Address[is.na(NEA_Subgrants_16$AFFGEOID)], 
        complete_spatial$Full_Address)]

table(is.na(NEA_Subgrants_16$AFFGEOID))


