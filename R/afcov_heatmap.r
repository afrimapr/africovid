#' plot heatmap of subnational covid data
#'
#' *in progress
#' to show cases or deaths
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param attribute attribute to plot, from dfhera
#' @param language 'which admin level to return'en' or 'fr' for country name
# @param plot
#'
#'
# @examples
# afcov_heatmap('Mali')
#'
#' @return \code{ggplot}
#' @importFrom ggplot2 ggplot aes_string geom_tile theme_classic labs scale_fill_distiller scale_x_date theme element_blank
#' @importFrom lubridate parse_date_time
#' @export
#'
#'
afcov_heatmap <- function(country,
                          attribute = 'CONTAMINES',
                          language = 'en'
                         )
{

  #TODO allow date range to be specified (x axis month breaks will need to cope)

  #TODO get this to cope with fuzzy country names

  #could convert from assumed English name to iso3c/iso_a3 using countrycode but maybe keep dependencies down

  if (language == 'en')
  {
    dfcountry <- dfhera[which(tolower(dfhera$name_en)==tolower(country)),]
  } else
  {
    dfcountry <- dfhera[which(tolower(dfhera$PAYS)==tolower(country)),]
  }


  #this heatmap by region of cases, loosely based on Colin Angus work looks good
  #TODO could add rolling 7 day averages to it

  month_breaks <- as.Date(lubridate::parse_date_time(c("2020-04","2020-05","2020-06","2020-07","2020-08","2020-09","2020-10","2020-11","2020-12","2021-01"), orders="ym"))

  ggplot2::ggplot(dfcountry, aes_string(x='date', y='REGION', fill=as.name(attribute)))+
    geom_tile(colour="White")+
    theme_classic()+
    #scale_fill_distiller(palette="Spectral") +
    #scale_fill_viridis_c()+
    scale_x_date(name="Date", expand=c(0,0), breaks=month_breaks, date_labels = "%b")+ #%b 3 char month, %B full month name
    scale_fill_distiller(palette="YlGnBu", direction=1, na.value='white') +
    labs(title=paste("Timelines for COVID-19 cases in ",country),
         #subtitle=paste0(""),
         caption="Data from @HeraAfrica via @humdata | Plot by @afrimapr")+
    theme(axis.line.y=element_blank())

}
