#' join geoboundaries admin names onto the hera data to allow joining to a map later
#'
#' *in progress
#'
#'
# @param country a character vector of country names or iso3c character codes.
# @param plot
#'
#'
# @examples
# join_all_subnat_to_map()
#'
#' @return dataframe

#' @importFrom sf st_drop_geometry
#' @export
#'
#' TODO change name of function
join_all_subnat_to_map <- function( )
{

  iso3cs <- unique(dfhera$ISO_3)

  #Ghana & Gambia fail because not possible to convert names
  #TODO create a loop to make a multicountry lookup file, excluding Ghana & Gambia
  #later change name of join_subnat_to_map which actually returns a 2 column dataframe of name conversions

  iso3cs <- iso3cs[-which( iso3cs %in% c("GHA","GMB"))]

  lookup_hera_geob <- NULL

  for( iso3c in iso3cs )
  {
    admin_level <- 1
    sfadmin <- afriadmin::afriadmin(iso3c, level=admin_level, datasource='geoboundaries', plot=FALSE)

    lookup_this_country <- join_subnat_to_map(country = iso3c)

    lookup_hera_geob <- rbind(lookup_hera_geob, lookup_this_country)

  }

  dfhera2 <- dplyr::left_join(dfhera, lookup_hera_geob, by=c("REGION" = "nameshera"))

  #TODO then I can resave the hera data in the package with the geob ids as a column
  #can also save a mapshapered version of admin boundaries to make it easy to
  #make maps with just africovid
  return(dfhera2)


}
