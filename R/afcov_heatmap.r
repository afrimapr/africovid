#' plot heatmap of subnational covid data
#'
#' *in progress
#' to show cases or deaths
#' Initial ggplot code copied from https://github.com/VictimOfMaths/COVID-19/blob/master/Heatmaps/English%20LA%20Heatmaps.R
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param attribute attribute to plot, from dfhera
#' @param areanames name of column containing the area names ('namesgeob' added to match geoboundaries, 'REGION' is in raw data )
#' @param dates either 'all', 'last' or c(start,end) in format "2021-01-31"
# @param att_title to include in the title - allows first go at language conversion from app
#' @param language 'which admin level to return'en' or 'fr' for country name
#' @param legend.position default "top", options "left","right","bottom"
#' @param palette RColorBrewer palette options default="YlGnBu"
#' @param date_legend axis breaks to appear in plots
#' @param timeinterval optional interval to sum over, options e.g. "5 days" "week" "month"
# @param plot
#'
#'
#' @examples
#'
#' afcov_heatmap('Mali')
#'
#' afcov_heatmap('senegal', dates=c("2021-01-01","2021-04-01"))
#'
#' @return \code{ggplot}
#' @importFrom ggplot2 ggplot aes_string geom_tile theme_classic labs scale_fill_distiller scale_x_date theme element_blank
#' @importFrom lubridate parse_date_time
#' @export
#'
#'
afcov_heatmap <- function(country,
                          attribute = 'CONTAMINES',
                          areanames = 'namesgeob', #'REGION'
                          dates = 'all',
                          #att_title = 'cases',
                          language = 'en',
                          legend.position="top",
                          palette="YlGnBu",
                          timeinterval=NULL,
                          date_legend=c("2020-04","2020-05","2020-06","2020-07","2020-08","2020-09","2020-10","2020-11","2020-12","2021-01","2021-02","2021-03","2021-04","2021-05")
                         )
{

  #subset by country & optionally date
  dfcountry <- afcov(country=country, dates=dates, language=language, timeinterval=timeinterval)

  # create year column for facet https://stackoverflow.com/questions/20571306/multi-row-x-axis-labels-in-ggplot-line-chart
  dfcountry <- dplyr::mutate(dfcountry, year = as.factor(lubridate::year(date)))

  #heatmap by region loosely based on Colin Angus work looks good
  month_breaks <- as.Date(lubridate::parse_date_time(date_legend, orders="ym"))

  ggplot2::ggplot(dfcountry, aes_string(x='date', y=areanames, fill=as.name(attribute)))+
    geom_tile(colour="White")+
    theme_classic()+
    #scale_fill_distiller(palette="Spectral") +
    #scale_fill_viridis_c()+
    scale_x_date(name="Date", expand=c(0,0), breaks=month_breaks, date_labels = "%b")+ #%b 3 char month, %B full month name

    #add year facets - if included the switch would appear on lower axis
    facet_grid(.~ year, space = 'free_x', scales = 'free_x') + #, switch = 'x') +
    # remove facet spacing on x-direction
    theme(panel.spacing.x = unit(0,"line")) +

    scale_fill_distiller(palette=palette, direction=1, na.value='white') +
    labs(title=paste("COVID-19 ",country),
    #labs(title=paste("COVID-19 ",attribute,",",country),
         #subtitle=paste0(""),
         caption="Data from @HeraAfrica via @humdata | Plot by @afrimapr")+
    ylab(NULL)+
    theme(axis.line.y=element_blank(),
          legend.position = legend.position)

}
