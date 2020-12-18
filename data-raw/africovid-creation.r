# africovid-creation.r

# steps to create package & data

# andy south


library(usethis)

#create new Github repo
#create new RStudio project from the github repo


usethis::create_package(getwd()) #to make a basic package.

use_gpl3_license()

use_data_raw() # then rename file & edit to this




#usethis::use_data(DATASET, overwrite = TRUE)
