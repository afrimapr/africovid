#' join subnational data to map of admin boundaries
#'
#' in progress
#'
#'
#' @param country a character vector of country names or iso3c character codes.
# @param plot
#'
#'
# @examples
# join_subnat_to_map('senegal')
#'
#' @return dataframe

# @importFrom sf st_drop_geometry
#' @export
#'
#'
join_subnat_to_map <- function( country = 'senegal' )
{

  #check and convert country names to iso codes
  #copes better with any naming differences
  iso3c <- country2iso(country)

  admin_level <- 1

  sfadmin <- afriadmin::afriadmin(country, level=admin_level, datasource='geoboundaries', plot=FALSE)

  # names from geoboundaries
  namesgeob <- unique(sfadmin$shapeName)
  # add this on because it is in Hera
  namesgeob <- c(namesgeob, 'Non spécifié') #'not_specified')
  # sort to make sure in same order
  namesgeob <- sort(namesgeob)

  # names from hera
  dfcountry <- dfhera[which(dfhera$ISO_3==iso3c),]
  nameshera <- unique(dfcountry$REGION)
  # sort to make sure in same order
  nameshera <- sort(nameshera)

  #library(waldo) #good job of displaying differences, but in text not v useful
  # tst1 <- waldo::compare(nameshera, namesgeob, max_diffs = Inf)
  # #this, used under, the hood may be more useful
  # tst2 <- diffobj::ses_dat(nameshera, namesgeob)
  # #also see daff which creates a 'patch' that can be applied
  # tst3 <- daff::diff_data(data.frame(nameshera), data.frame(namesgeob))

  #simpler approach may be just to rbind the nameshera & namesgeob,
  #& then leftjoin hera data to it which should add a nameshera column to the geob data
  #making it easier later to join any

  #I want to arrive at hera data that also has namesgeob (shapeName)
  #will also work for not_specified once country is subsetted

  #TODO check length of the 2 names objects they should be same

  lookup_hera_geob <- cbind(data.frame(nameshera), data.frame(namesgeob))


  return(lookup_hera_geob)

  # cool this does work for one country
  #dfhera2 <- dplyr::left_join(dfhera, lookup_hera_geob, by=c("REGION" = "nameshera"))

  # TODO maybe loop through by country present to create a master version of lookup_hera_geob
  # & first check that each works

  #unique(dfhera$name_en)

  # country <- "Nigeria"
  # country <- "Ghana"
  # country <- "Niger"
  # country <- "Mali"
  # country <- "Senegal"
  # country <- "Mauritania"
  # country <- "Benin" #only til October
  # country <- "Gambia" #only til October
  # country <- "Togo"
  # country <- "Burkina Faso"

  # Ghana Hera has 17 regions, Geob has 11
  # old             | new
  # [1] "Ashanti"       | "Ashanti"       [1]
  # [2] "Bono"          -
  # [3] "Bono East"     -
  # [4] "Brong Ahafo"   | "Brong Ahafo"   [2]
  # [5] "Central"       | "Central"       [3]
  # [6] "Eastern"       | "Eastern"       [4]
  # [7] "Greater Accra" | "Greater Accra" [5]
  # [8] "Non spécifié"  | "Non spécifié"  [6]
  # [9] "North East"    -
  # [10] "Northern"      | "Northern"      [7]
  # [11] "Oti"           -
  # [12] "Savannah"      -
  # [13] "Upper East"    | "Upper East"    [8]
  # [14] "Upper West"    | "Upper West"    [9]
  # [15] "Volta"         | "Volta"         [10]
  # [16] "Western"       | "Western"       [11]
  # [17] "Western North" -

  #Niger - should work - note space after Tahoua
  #"Tahoua " "Tillabéry"
  #"Tahoua"  "Tillabery"

  #Mali 2 differences, works
  #"Koulikoro"   "Ségou"
  #"Koulikouro"  "Segou"

  #Mauritania - 5 differences - works
  # [4] "Dakhlet Nouadhibou" - "Dakhlet-Nouadhibou" [4]
  # [6] "Guidimaka"          - "Guidimakha"         [6]
  # [7] "Hodh ech Chargui"   - "Hodh Ech Chargi"    [7]
  # [8] "Hodh el Gharbi"     - "Hodh El Gharbi"     [8]
  # [13] "Tiris Zemmour"      - "Tiris-Zemmour"      [13]

  #Togo - all v. different, fortunately sort order retained so it works
  # [1] "Centre"       - "Centrale Region" [1]
  # [2] "Kara"         - "Kara Region"     [2]
  # [3] "Maritime"     - "Maritime Region" [3]
  # [4] "Non spécifié" | "Non spécifié"    [4]
  # [5] "Plateaux"     - "Plateaux Region" [5]
  # [6] "Savanes"      - "Savanes Region"  [6]

  #Burkina Faso 2 differences, works
  # [9] "Haut-Bassins"    - "Hauts-Bassins"   [9]
  # [12] "Plateau-Central" - "Plateau Central" [12]

  #Benin, no differences :-)

  #Gambia - completely different !
  # [1] "Central River"   - "Banjul"       [1]
  # [2] "Lower River"     - "Basse"        [2]
  #                       - "Brikama"      [3]
  #                       - "Janjanbureh"  [4]
  #                       - "Kanifing"     [5]
  #                       - "Kerewan"      [6]
  #                       - "Kuntaur"      [7]
  #                       - "Mansa Konko"  [8]
  #
  # [4] "North Bank East" -
  # [5] "North Bank West" -
  # [6] "Upper River"     -
  # [7] "Western One"     -
  # [8] "Western Two"     -

  #so it is only Ghana & Gambia that fail because not possible to convert names


  #TODO create a loop to make a multicountry lookup file, excluding Ghana & Gambia
  #maybe change the name of this function & call it



}
