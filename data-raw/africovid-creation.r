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


#21 subnational datasets (2020-12-14 & 2021-01-17)
#26 subnational datasets (2021-05-16)
ds <- search_datasets("hera subnational", rows=99)
#below returned 49 including city level datasets
#ds <- search_datasets("hera Coronavirus subnational", rows=99)

#trying to read them all into single dataframe

#2021-01-17
#11 Liberia has problems with DATE column, stops in May, doesn't have an ID column
#15 is called a web app and fails to load
#16 & later are cumulative for all Africa & different columns
#to_exclude <- c(11,15,16,17,18,19,20,21)

#2021-05-16 finding which datsets to include/exclude
#here sapply provides a simplified vector of all dataset titles
sapply(ds,function(x) x$data$title)

#which to exclude by visually inspecting list
to_exclude <- c(2,14,18:26)
# [1] "Nigeria: Coronavirus  (Covid-19) Subnational"
# [2] "Guinea: Ebola (2021) Subnational cases"
# [3] "Mali: Coronavirus (Covid-19) Subnational"
# [4] "Ghana: Coronavirus (Covid-19) Subnational"
# [5] "Niger: Coronavirus (Covid-19) Subnational"
# [6] "Mauritania: Coronavirus (Covid-19) Subnational"
# [7] "Senegal : Coronavirus (Covid-19) Subnational"
# [8] "Togo: Coronavirus (Covid-19) Subnational"
# [9] "Gambia: Coronavirus (Covid-19) Subnational"
# [10] "Bénin: Coronavirus (Covid-19) Subnational"
# [11] "Burkina Faso: Coronavirus (Covid-19) Subnational"
# [12] "Liberia: Coronavirus (Covid-19) Subnational"
# [13] "Guinea: Coronavirus (Covid-19) Subnational"
# [14] "Democratic Republic of the Congo: Ebola (2021) Subnational cases"
# [15] "Democratic Republic of the Congo: Coronavirus  (Covid-19) Subnational"
# [16] "Côte d'Ivoire: Coronavirus (Covid-19) Subnational"
# [17] "Sierra Leone: Coronavirus (Covid-19) Subnational"
# [18] "Africa: Coronavirus (COVID-19) Subnational Cases"
# [19] "Democratic Republic of the Congo : Ebola (2021) Cumulative cases (national)"
# [20] "Guinea: Ebola (2021) Cumulative cases (national)"
# [21] "Africa: Covid-19 Infections (National)"
# [22] "Africa: Covid-19 Cumulative Recoveries (National)"
# [23] "Africa: Covid-19 Cumulative infections (National)"
# [24] "Africa: Covid-19 Cumulative Deaths (National)"
# [25] "Africa: Covid-19 Recoveries (National)"
# [26] "Africa: Covid-19 Death cases (National)"

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
  #skip Liberia above
  #2021-05-16 Cote d'Ivoire doesn't have an ID column either
  if (names(df1)[1]=='DATE')
  {
    #next #to miss out Liberia
    #df1 <- NULL #set to NULL to miss Liberia out for now
    dfid <- tibble(ID=1:nrow(df1))
    df1 <- cbind(dfid,df1)
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
  #if ("Femme" %in% names(df1))
  #  names(df1) <- names(dfall)

  #remove this column that occurs in just some ds e.g Gambia
  if ('LIEN SOURCE' %in% names(df1))
    df1 <- dplyr::select(df1, !`LIEN SOURCE`)

  #2021-05-16 senegal now has added vaccination columns, breaks reading into combined dataframe
  #remove thos columns for now
  if ("NOUVEAUX_INDIVIDUS_VACCINES" %in% names(df1))
    df1 <- dplyr::select(df1, !"NOUVEAUX_INDIVIDUS_VACCINES")

  if ("TOTAL_INDIVIDUS_VACCINES (1 dose)" %in% names(df1))
    df1 <- dplyr::select(df1, !`TOTAL_INDIVIDUS_VACCINES (1 dose)`)

  #remove these columns that appear just in some case Sierra Leone
  if ('LIEN WEB' %in% names(df1))
    df1 <- dplyr::select(df1, !`LIEN WEB`)

  if ('x15' %in% names(df1))
    df1 <- dplyr::select(df1, !`x15`)
  if ('X15' %in% names(df1))
    df1 <- dplyr::select(df1, !`X15`)

  #2021-05-16 correcting fieldnames for Cote d'Ivoire
  if ('Contaminés' %in% names(df1))
    df1 <- dplyr::rename(df1, CONTAMINES = Contaminés)
  if ('Décès' %in% names(df1))
    df1 <- dplyr::rename(df1, DECES = Décès)
  if ('Guéris' %in% names(df1))
    df1 <- dplyr::rename(df1, GUERIS = Guéris)
  if ('Femme' %in% names(df1))
    df1 <- dplyr::rename(df1, CONTAMINES_FEMME = Femme)
  if ('Homme' %in% names(df1))
    df1 <- dplyr::rename(df1, CONTAMINES_HOMME = Homme)
  if ("Genre_non spécifié" %in% names(df1))
    df1 <- dplyr::rename(df1, CONTAMINES_GENRE_NON_SPECIFIE = `Genre_non spécifié`)

  #bind these country rows onto all country rows
  dfall <- rbind(dfall, df1)
}


#2021-05-16 694 rows with NA for PAYS ISO_3 ID_PAYS etc., some are Nigeria
tstna <- filter(dfall,is.na(PAYS))
# TODO fill in these NAs


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
