## Instructions: 
## Go to this website to access most recent version of IRS BMF:
## https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf

## 1. download all 4 Region Files: Region 1, Region 2, Region 3, Region 4, 
## and put them in the same folder in your drive. They'll be called
# eo1.csv, eo2.csv, eo3.csv, eo4.csv

## 2. set working directory to folder containing all the 4 Regional files
setwd("~/Desktop/NEA data/Nonprofit File - 073117")

## 3. read in all files (will take a few moments due to file size)
region_1<-read.csv("eo1.csv", stringsAsFactors=F)
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

library(stringr)
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

## 10. Add in all required geographic variables 

library(devtools)
install_github("gmellon/neaR")
library(neaR)

# Clean Address
IRS$address<- create_full_address(data = IRS, address.vars = c("STREET","CITY", "STATE",
                                                               "ZIP"))
IRS$address<-gsub("/", "", IRS$address)

#Geocode

coords <- neaR::get_geocode_data(IRS$address)

IRS$Latitude <- coords$lat
IRS$Longitude <- coords$lon

#create international flag 
IRS$is.international<-create_intl_flag(IRS$STATE)

## APPEND MSAs
msa.info <- get_msa_data(Latitude = IRS$Latitude, Longitude = IRS$Longitude)

IRS$msa_GEOID <- msa.info$cbsa_GEOID
IRS$msa_NAMELSAD <- msa.info$cbsa_NAMELSAD
IRS$msa_LSAD <- msa.info$cbsa_LSAD
IRS$msa_source <-msa.info$source


# backup, periodically: write.csv(IRS, "nonprofits_file_backup.csv")

### Add MSA Population from File

msa_pop <- read.csv("PEP_2016_GCTPEPANNR.US23PR_with_ann.csv", stringsAsFactors=F)

IRS$msa_pop<-NA
IRS$msa_pop[is.na(IRS$msa_pop)]<-msa_pop$msa_pop_2016[match(IRS$msa_GEOID[is.na(IRS$msa_pop)],
                                                            msa_pop$GEOID) ] 

IRS$msa_pop[which(IRS$msa_NAMELSAD=="Lewiston-Auburn, ME Metropolitan NECTA")]<-106799
IRS$msa_pop[which(IRS$msa_NAMELSAD=="Bangor, ME Metropolitan NECTA")]<-131085
IRS$msa_pop[which(IRS$msa_NAMELSAD=="Burlington-South Burlington, VT Metropolitan NECTA")]<-212924
IRS$msa_pop[which(is.na(IRS$msa_GEOID))]<-NA
IRS$msa_source[which(is.na(IRS$msa_GEOID))]<-NA

# create urban/rural flag
IRS$rural.urban.flag<-create_boolean_urban(IRS$msa_LSAD, IRS$Latitude) 
IRS$urban.type<-create_urban_type(IRS$msa_pop, IRS$rural.urban.flag) 

# Append Census Tracts 

tract.info <- get_ct_data(Latitude = IRS$Latitude, Longitude = IRS$Longitude)
IRS$CT_NAMELSAD <- tract.info$CT_NAMELSAD
IRS$CT_GEOID <- tract.info$CT_GEOID

IRS$poverty_rate<-NA
IRS$poverty_rate<-append_poverty_data(IRS$CT_GEOID, IRS$poverty_rate)
IRS$poverty_flag<-create_poverty_flag(IRS$poverty_rate, IRS$CoLatitude)

#11. Clean Up International Records  - they should be "NAs" for the Columns shown below

IRS$urban.type[which(IRS$is.international==T)]<-"International"
IRS$rural.urban.flag[which(IRS$is.international==T)]<-"International"
IRS$poverty_rate[which(IRS$is.international==T)]<-"International"
IRS$poverty_flag[which(IRS$is.international==T)]<-"International"

## Revenue Metric: Use REVENUE_AMT to create breakouts
IRS$Revenue_Categories<-NA
IRS$Revenue_Categories[IRS$REVENUE_AMT<50000]<-"1-Less than $50,000"
IRS$Revenue_Categories[IRS$REVENUE_AMT>50000 & IRS$REVENUE_AMT<100000]<-"2-At least $50,000 but less than $100,000"
IRS$Revenue_Categories[IRS$REVENUE_AMT>100000 & IRS$REVENUE_AMT<500000]<-"3-At least $100,000 but less than $500,000"
IRS$Revenue_Categories[IRS$REVENUE_AMT>500000 & IRS$REVENUE_AMT<1000000]<-"4-At least $500,000 but less than $1 million"
IRS$Revenue_Categories[IRS$REVENUE_AMT>1000000]<-"5- $1 million or more"
IRS$Revenue_Categories[(is.na(IRS$REVENUE_AMT)|IRS$REVENUE_AMT==0)  & IRS$FILING_REQ_CD==2]<-"88 - Not reported (Form 990N)"
IRS$Revenue_Categories[is.na(IRS$REVENUE_AMT) & IRS$FILING_REQ_CD!=2]<-"89 - Not reported"

# IRS NTEE_ARTS CATEGORY: Create based on NEA Definitions

# create a new column with 3 digits and trailing zero, if needed 
library(stringr)
IRS$NTEE_3_Digits<-str_sub(IRS$NTEE_CD,1,3)
library(stringi)
IRS$NTEE_3_Digits<- stri_pad_right(IRS$NTEE_3_Digits, 3, 0)
IRS$NTEE_3_Digits<- gsub( "X", "0", IRS$NTEE_3_Digits)
IRS$NTEE_3_Digits<- gsub( "O", "0", IRS$NTEE_3_Digits)


IRS$ARTS_CATEGORY<-NA
IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A01", "A02", "A03", "A05", 
                                           "A11", "A12", "A19", "A90" )]<-"Group 1: Advocacy, Management, and Technical Services" 

IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A20", "A23", "A24", "A40", "A25", 
                                           "A26", "A27", "A6E", "A99") ]<-"Group 2: Arts Centers, Arts Education, and Other Arts Organizations" 

IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A30", "A31", "A32", 
                                           "A33", "A34") ]<-"Group 3: Media & Communications" 

IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A50", "A51", "A52",
                                           "A53", "A54", "A56", "A57") ]<-"Group 4: Museums" 

IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A60", "A6E", "A61", "A62", 
                                           "A63", "A65", "A68", "A69", "A6A", "A6B", "A6C") ]<-"Group 5: Performing Arts" 

IRS$ARTS_CATEGORY[IRS$NTEE_3_Digits %in% c("A70",
                                           "A80", "A82", "A84") ]<-"Group 6: Humanities, Historical Organizations, and Commemorative Events" 

IRS$ARTS_CATEGORY[is.na(IRS$ARTS_CATEGORY)]<-"Other"


## Write a new final csv file that will include all the merges and processes
## done in the steps above. The file will be located in the same folder
write.csv(IRS, "arts_nonprofits_080317.csv")
