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

# data creation & update now in update_data()

#usethis::use_data(dfhera, overwrite = TRUE)
