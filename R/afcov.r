#' to return subnational covid data by country and optionally date
#'
#' *in progress
#'
#' @param country a character vector of country names or iso3c character codes.
# @param attribute attribute to plot, from dfhera
#' @param dates either 'all', 'last' or c(start,end) in format "2021-01-31"
#' @param language 'which admin level to return 'en' or 'fr' for country name
# @param plot
#'
#'
# @examples
# afcov('Mali')
#'
#' @return dataframe
# @importFrom lubridate parse_date_time
#' @export
#'
#'
afcov <- function(country,
                          #attribute = 'CONTAMINES',
                          #att_title = 'cases',
                          language = 'en',
                          dates = 'all'
                         )
{

  #TODO move country subset into own function, shared with afcov_heatmap

  if (language == 'en')
  {
    dfcountry <- dfhera[which(tolower(dfhera$name_en)==tolower(country)),]
  } else
  {
    dfcountry <- dfhera[which(tolower(dfhera$PAYS)==tolower(country)),]
  }


  # if (isFALSE(dates == "all"))
  # {

    if (isTRUE(dates=='last'))
    {
      date_one <- max(dfcountry$date)

      date_indices <- which(dfcountry$date==date_one)

    } else if (isTRUE(dates=='last6days'))
    {
      date_one <- max(dfcountry$date)

      date_indices <- which(dfcountry$date > lubridate::date(date_one)-6 &
                              dfcountry$date <= date_one )

    }
  else if (length(dates)==2) #if start & end date
    {

      date_indices <- which(dfcountry$date >= dates[1] &
                            dfcountry$date <= dates[2] )

    } else if (isTRUE(dates=='all'))
    {

      #all indices, bit of a fudge just because I failed to trap 'all' without problem of start,stop vector
      date_indices <- 1:nrow(dfcountry)

    } else #i.e. one date specified
    {

      date_indices <- which(dfcountry$date==dates)

    }

    #subset by date indices
    dfcountry <- dfcountry[date_indices,]

  #}


  invisible(dfcountry)

}
