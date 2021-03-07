#' to return subnational covid data by country and optionally date
#'
#' *in progress
#'
#' @param country a character vector of country names or iso3c character codes.
# @param attribute attribute to plot, from dfhera
#' @param language 'which admin level to return 'en' or 'fr' for country name
#' @param dates either 'all', 'last' or c(start,end) in format "2021-01-31"
#' @param timeinterval optional interval to sum over, options e.g. "5 days" "week" "month"
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
                          dates = 'all',
                          timeinterval = NULL
                         )
{


  if (language == 'en')
  {
    dfcountry <- dfhera[which(tolower(dfhera$name_en)==tolower(country)),]
  } else
  {
    dfcountry <- dfhera[which(tolower(dfhera$PAYS)==tolower(country)),]
  }



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

    # optional aggregating of data by days weekd, months
    # TODO need to identify all attribute variables to aggregate
    # TODO try other time periods
    # timeinterval <- "10 days"
    # timeinterval <- "week"
    # timeinterval <- "month"
    #
    if (! is.null(timeinterval))
    {
      dfcountry <- dfcountry %>%
        group_by(namesgeob, date = ceiling_date(date, timeinterval)) %>%
        summarize(CONTAMINES=sum(CONTAMINES, na.rm=TRUE),
                  DECES=sum(DECES, na.rm=TRUE),
                  GUERIS=sum(GUERIS, na.rm=TRUE),
                  CONTAMINES_FEMME=sum(CONTAMINES_FEMME, na.rm=TRUE),
                  CONTAMINES_HOMME=sum(CONTAMINES_HOMME, na.rm=TRUE),
                  CONTAMINES_GENRE_NON_SPECIFIE=sum(CONTAMINES_GENRE_NON_SPECIFIE, na.rm=TRUE),
                  days = n())
    }

    ""
    # [10] "GUERIS"                        "CONTAMINES_FEMME"              "CONTAMINES_HOMME"
    # [13] "CONTAMINES_GENRE_NON_SPECIFIE"

    # dat %>%
    #   group_by(decade=if_else(day(date) >= 30,
    #                           floor_date(date, "20 days"),
    #                           floor_date(date, "10 days"))) %>%
    #   summarize(acum_rainfall=sum(rainfall),
    #             days = n())


  invisible(dfcountry)

}
