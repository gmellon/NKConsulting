## Instructions: 
## Go to this website to access most recent version of IRS BMF:
## https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf

## 1. download all 4 Region Files: Region 1, Region 2, Region 3, Region 4, 
## and put them in the same folder in your drive. They'll be called
# eo1.csv, eo2.csv, eo3.csv, eo4.csv

## 2. set working directory to folder containing all the 4 Regional files
setwd("~/Desktop/NEA data/Nonprofit File - 073117")

## 3. read in all files (will take a few moments due to file size)
region_1<-read.csv( "eo1.csv", stringsAsFactors=F)
region_2<-read.csv("eo2.csv", stringsAsFactors=F)
region_3<-read.csv("eo3.csv", stringsAsFactors=F)
region_4<-read.csv("eo4.csv", stringsAsFactors=F)

## 4. add in new "Region" variable in all files to indicate source file
region_1$Region<-"Region 1"
region_2$Region<-"Region 2"
region_3$Region<-"Region 3"
region_4$Region<-"Region 4"

## 5. Bind all files together using row binding, since columns
## are all in same order in each file
IRS<- rbind(region_1,region_2, region_3, region_4 )

## 6. Use NTEE Code Variable to create new "NTEE_Category" Variable
## We'll use to subset all "A" Categories

IRS$NTEE_Category<-str_sub(IRS$NTEE_CD,1,1)

## 7. Subset File to just "A" NTEE Codes, Using variable constructed in 
## previous step 
IRS<-IRS[which(IRS$NTEE_Category=="A"),]

## 8. Add new variables that describe financial variables in the file. 

IRS$ASSET_CD_DESCRIPTION<-NA
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==0]<-"0"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==1]<-"1 to 9,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==2]<-"10,000 to 24,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==3]<-"25,000 to 99,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==4]<-"100,000 to 499,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==5]<-"500,000 to 999,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==6]<-"1,000,000 to 4,999,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==7]<-"5,000,000 to 9,999,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==8]<-"10,000,000 to 49,999,999"
IRS$ASSET_CD_DESCRIPTION[IRS$ASSET_CD==9]<-"50,000,000 to greater"

IRS$INCOME_CD_DESCRIPTION<-NA
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==0]<-"0"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==1]<-"1 to 9,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==2]<-"10,000 to 24,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==3]<-"25,000 to 99,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==4]<-"100,000 to 499,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==5]<-"500,000 to 999,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==6]<-"1,000,000 to 4,999,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==7]<-"5,000,000 to 9,999,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==8]<-"10,000,000 to 49,999,999"
IRS$INCOME_CD_DESCRIPTION[IRS$INCOME_CD==9]<-"50,000,000 to greater"

## 9. Add in new variable with IRS BMF Vintage and Creation Date

IRS$Source_File<- "IRS EO BMF 071117"
IRS$File_Creation_Date<- "July 31, 2017"

## Write a new final csv file that will include all the merges and processes
## done in the steps above. The file will be located in the same folder

write.csv(IRS, "arts_nonprofits_073117.csv")