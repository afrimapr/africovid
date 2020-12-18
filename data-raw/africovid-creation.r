# africovid-creation.r

# steps to create package & data

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
df2 <- search_datasets("hera", rows = 2) %>%
  pluck(1) %>% ## select the first dataset
  get_resource(2) %>% ## 2nd resource is csv
  read_resource(delim=';')

#Ahmadou example from issue 8
pull_dataset("mauritania_covid19_subnational") %>%
  get_resources(format = "csv") %>%
  pluck(1) %>%
  read_resource(delim = ";", locale = locale(decimal_mark = ","))



# this does return hera datasets
ds <- search_datasets("hera", rows=99)

#default returns 10

#this returns 21 subnational datasets
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
    read_resource(delim = ";", locale = locale(decimal_mark = ",")) # read into R

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


usethis::use_data(dfhera, overwrite = TRUE)
