# africovid-creation.r

# steps to create package & data
# NOTE regular data update stuff now copied to update_data()

# andy south


library(usethis)

#create new Github repo
#create new RStudio project from the github repo


usethis::create_package(getwd()) #to make a basic package.

use_gpl3_license()

use_data_raw() # then rename file & edit to this

library(rhdx)       #to get data from HDX
library(tidyverse)  #data manipulation

set_rhdx_config(hdx_site = "prod")
get_rhdx_config()

#modified example from readme
# df2 <- search_datasets("hera", rows = 2) %>%
#   pluck(1) %>% ## select the first dataset
#   get_resource(2) %>% ## 2nd resource is csv
#   read_resource(delim=';')
#
# #Ahmadou example from issue 8
# pull_dataset("mauritania_covid19_subnational") %>%
#   get_resources(format = "csv") %>%
#   pluck(1) %>%
#   read_resource(delim = ";", locale = locale(decimal_mark = ","))


# this does return hera datasets
#ds <- search_datasets("hera", rows=99)


#this returns 21 subnational datasets (2020-12-14 & 2021-01-17)
ds <- search_datasets("hera subnational", rows=99)

#trying to read them all into single dataframe

#11 Liberia has problems with DATE column, stops in May, doesn't have an ID column
#15 is called a web app and fails to load
#16 & later are cumulative for all Africa & different columns
to_exclude <- c(11,15,16,17,18,19,20,21)
ds <- ds[-to_exclude]

dfall <- NULL

for( i in 1:length(ds))
{
  cat(i)

  # df1 <- get_resource(ds[[i]], 1) %>% ## 1st resource is XLS (csv is ; delimited causing problems)
  #        read_resource() # read into R

  #df1 <- get_resource(ds[[i]], 2) %>% ## 2nd resource is csv
  df1 <- get_resources(ds[[i]], format = "csv") %>%
    pluck(1) %>% ## select the first csv
    # read into R, force_download to make sure get latest version
    read_resource(delim = ";", locale = locale(decimal_mark = ","), force_download = TRUE)

  #should work too
  #get_resources(format = "csv") %>%

  #Liberia stops in May, doesn't have an ID column
  #also gives this error, probably to do with dates
  #Error in as.POSIXlt.character(x, tz, ...) :
  #character string is not in a standard unambiguous format
  if (names(df1)[1]=='DATE')
  {
    next #to miss out Liberia
    #df1 <- NULL #set to NULL to miss Liberia out for now
    # dfid <- tibble(ID=1:nrow(df1))
    # df1 <- cbind(dfid,df1)
  }

  #some, but not all xls files, read rownames into first column
  if (df1[[1,1]] == 'ID')
  {
    #set column names from 1st row
    names(df1) <- as.character(df1[1,])
    #remove first row
    df1 <- df1[-1,]
  }

  #Benin stops in October and has different named columns, title case rather than upper case
  #patch to fix it
  if ("Femme" %in% names(df1))
    names(df1) <- names(dfall)

  #remove this column that occurs in just some ds e.g Gambia
  if ('LIEN SOURCE' %in% names(df1))
    df1 <- dplyr::select(df1, !`LIEN SOURCE`)

  #bind these country rows onto all country rows
  dfall <- rbind(dfall, df1)
}

#7 Gambia with csv
# Warning: 1365 parsing failures.
#  row                           col expected actual                                                                              file
# 1081 CONTAMINES                    a double   null 'C:/Users/andy.south/AppData/Local/Cache/R/rhdx/gmb_subnational_covid19_hera.csv'

#saving the data object for all countries
dfhera <- dfall

# unique(dfhera$PAYS)
# [1] "Nigéria"      "Ghana"        "Mali"         "Niger"        "Mauritanie"   "Sénégal"      "Gambie"
# [8] "Togo"         "Bénin"        "Burkina Faso"

names(dfhera)
# [1] "ID"                            "DATE"                          "ISO_3"
# [4] "PAYS"                          "ID_PAYS"                       "REGION"
# [7] "ID_REGION"                     "CONTAMINES"                    "DECES"
# [10] "GUERIS"                        "CONTAMINES_FEMME"              "CONTAMINES_HOMME"
# [13] "CONTAMINES_GENRE_NON_SPECIFIE" "SOURCE"

#convert dates to useable format
library(lubridate)
dfhera$date <- lubridate::dmy(dfhera$DATE)

#convert numeric columns to numeric - seesm this shouldn't be necessary, tibble attributes indicate col_double()
dfhera$CONTAMINES <- as.numeric(dfhera$CONTAMINES)
dfhera$DECES <- as.numeric(dfhera$DECES)
dfhera$GUERIS <- as.numeric(dfhera$GUERIS)
dfhera$CONTAMINES_FEMME <- as.numeric(dfhera$CONTAMINES_FEMME)
dfhera$CONTAMINES_HOMME <- as.numeric(dfhera$CONTAMINES_HOMME)
dfhera$CONTAMINES_GENRE_NON_SPECIFIE <- as.numeric(dfhera$CONTAMINES_GENRE_NON_SPECIFIE)

##add countrycodes & english names

# library(countrycode)
# this doesn't work to convert from french destination
# below I use afrilearndata instead
# dfhera$iso3c <- countrycode(dfhera$PAYS, origin = 'country.name.fr', destination = 'iso3c')
# Error in countrycode(dfhera$PAYS, origin = "country.name.fr", destination = "iso3c") :
#   Origin code not supported by countrycode or present in the user-supplied custom_dict.

library(fuzzyjoin)
library(afrilearndata)
library(sf)

#create dataframe of nam, name_fr & iso_a3
#df1 <- dplyr::select(sf::st_drop_geometry(africountries), c(name,iso_a3,name_fr))
df1 <- dplyr::select(sf::st_drop_geometry(africountries), c(name,iso_a3))
names(df1)[1] <- 'name_en'

#test whether standard antijoin & fuzzyjoin copes with all the French names, should return 0 rows
anti_join(dfhera, df1, by=c(PAYS='name_fr'))
#stringdist_anti_join(dfhera, df1, by=c(PAYS='name_fr')) #, mode='left')

#arg stringdist_join matches Nigeria & Liberia !! detect by more rows in the df
#df2 <- stringdist_left_join(dfhera, df1, by=c(PAYS='name_fr')) #, mode='left')

#standard left join works based on either name_fr safer to use ISO_3
#dfhera <- left_join(dfhera, df1, by=c(PAYS='name_fr')) #, mode='left')
dfhera <- left_join(dfhera, df1, by=c(ISO_3='iso_a3')) #, mode='left')

# checking and correcting a few negative values
# 3 rows with negative values
# the one for Benin messes up Benin plot
dfneg <- dfhera[which(dfhera$CONTAMINES < 0),]

# ID DATE  ISO_3 PAYS  ID_PAYS REGION ID_REGION CONTAMINES DECES GUERIS CONTAMINES_FEMME CONTAMINES_HOMME
# 2276 23/0~ GHA   Ghana       4 Bono          40         -4    NA      0               NA               NA
# 3575 08/1~ GHA   Ghana       4 Great~        30        -44    NA    -15               NA               NA
#  845 19/0~ BEN   Bénin      10 Non s~       108       -209     0    -26               NA               NA

# here I assume that the neg symbol shouldn't be there so I remove it
negs <- which(dfhera$CONTAMINES < 0)
dfhera$CONTAMINES[negs] <- abs(dfhera$CONTAMINES[negs])
negs <- which(dfhera$GUERIS < 0)
dfhera$GUERIS[negs] <- abs(dfhera$GUERIS[negs])
negs <- which(dfhera$CONTAMINES_GENRE_NON_SPECIFIE < 0)
dfhera$CONTAMINES_GENRE_NON_SPECIFIE[negs] <- abs(dfhera$CONTAMINES_GENRE_NON_SPECIFIE[negs])

usethis::use_data(dfhera, overwrite = TRUE)
