#africovid/africovidviewer/server.r


cran_packages <- c("leaflet","remotes")
lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(remotes)
library(leaflet)
library(ggplot2)
#library(patchwork) #for combining ggplots


#global variables

# to try to allow retaining of map zoom, when type checkboxes are selected
zoom_view <- NULL
# when country is changed I want whole map to change
# but when input$hs_amenity or input$selected_who_cats are changed I want to retain zoom
# perhaps can just reset zoomed view to NULL when country is changed


function(input, output) {


  ########################
  # heatmap
  output$plot_heatmap <- renderPlot({


    gg1 <- africovid::afcov_heatmap(input$country,
                                    attribute=input$covid_measure)

    gg1

  })


  ######################################
  # map plot (not interactive)
  # output$plot_map_latest <- renderLeaflet({
  output$plot_map_latest <- renderPlot({

    mapplot <- afcov_map(input$country,
                         attribute=input$covid_measure)

    mapplot

    #if interactive
    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    #mapplot@map

  })

  ######################################
  # last 6 days facetted map plot (not interactive)
  output$plot_map_last6 <- renderPlot({

    mapplot <- afcov_map(input$country,
                         attribute=input$covid_measure,
                         dates='last6days')

    mapplot

  })

  #######################
  # table of raw data
  output$table_raw <- DT::renderDataTable({

    dfcountry <- dfhera[which(dfhera$name_en==input$country),]

    # drop the geometry column - not wanted in table
    #sfwho <- sf::st_drop_geometry(sfwho)

    DT::datatable(dfcountry, options = list(pageLength = 50))

  })




}
