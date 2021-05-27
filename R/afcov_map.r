#' plot map of subnational covid data by country
#'
#' *in progress
#' to show cases or deaths
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param attribute attribute to plot, from dfhera
#' @param dates either 'all', 'last' or c(start,end) in format "2021-01-31"
#' @param timeinterval optional interval to sum over, options e.g. "5 days" "week" "month"
# @param att_title to include in the title - allows first go at language conversion from app
#' @param language 'which admin level to return 'en' or 'fr' for country name
#' @param legend.position default "top", options "left","right","bottom"
#' @param palette RColorBrewer palette options default="YlGnBu"
# @param date_legend axis breaks to appear in plots
# @param plot
#'
#'
#' @examples
#' afcov_map('Mali')
#'
#' #a 6 daily facetted map
#' afcov_map('senegal', dates=c("2021-01-01","2021-01-06"))
#'
#' @return \code{ggplot}
#' @import ggplot2
# @importFrom ggplot2 ggplot aes_string geom_tile geom_sf theme_classic labs scale_fill_distiller scale_x_date theme element_blank
#' @export
#'
#'
afcov_map <- function(country,
                          attribute = 'CONTAMINES',
                          dates = 'last',
                          timeinterval=NULL,
                          #att_title = 'cases',
                          language = 'en',
                          legend.position="top",
                          palette="YlGnBu"
                          #date_legend=c("2020-04","2020-05","2020-06","2020-07","2020-08","2020-09","2020-10","2020-11","2020-12","2021-01","2021-02","2021-03")
                         )
{


  #subset by country & optionally date
  dfdate <- afcov(country=country, dates=dates, language=language, timeinterval=timeinterval)

  #join on to geoboundaries data
  #possibly save simplified version of geob sf objects in package
  sfadmin <- afriadmin::afriadmin(country, level=1, datasource='geoboundaries', plot=FALSE)

  sfadmin <- rmapshaper::ms_simplify(sfadmin, keep=0.2) #chosen 20% by eye

  # use merge instead of dplyr::left_join to reduce dependencies
  # but might be better to use dplyr given that want to encourage users to reuse building blocks
  sfadmin <- merge(sfadmin, dfdate, by.x='shapeName', by.y='namesgeob')

  # done with ggplot to keep down dependencies (already using it in africovid package)
  # tmap would also be an option
  # or mapview for interactive, but then facetting not possible

  #TODO allow summarising e.g. weekly monthly if multiple dates


  gg <- ggplot(sfadmin) +
    geom_sf(aes_string(fill = attribute)) +
    #scale_fill_viridis_c() +
    scale_fill_distiller(palette=palette, direction=1, na.value='white') +
    theme(legend.position = legend.position) +
    labs(title=paste("COVID-19 ",country),
           caption="Data from @HeraAfrica via @humdata | Plot by @afrimapr") +
    theme_void()

  # allowing facets if more than one date, this works
  if (length(unique(sfadmin$date)>1))
  {
    gg <- gg + facet_wrap(vars(date))

  }

  gg


  # ggplot2::ggplot(dfcountry, aes_string(x='date', y='REGION', fill=as.name(attribute)))+
  #   geom_tile(colour="White")+
  #   theme_classic()+
  #   #scale_fill_distiller(palette="Spectral") +
  #   #scale_fill_viridis_c()+
  #   scale_x_date(name="Date", expand=c(0,0), breaks=month_breaks, date_labels = "%b")+ #%b 3 char month, %B full month name
  #   scale_fill_distiller(palette="YlGnBu", direction=1, na.value='white') +
  #   labs(title=paste("COVID-19 ",country),
  #   #labs(title=paste("COVID-19 ",attribute,",",country),
  #        #subtitle=paste0(""),
  #        caption="Data from @HeraAfrica via @humdata | Plot by @afrimapr")+
  #   theme(axis.line.y=element_blank(),
  #         legend.position = legend.position)

}
