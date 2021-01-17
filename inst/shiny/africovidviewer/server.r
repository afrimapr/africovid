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


# Define a server for the Shiny app
function(input, output) {


  ########################
  # heatmap
  output$plot_heatmap <- renderPlot({


    gg1 <- africovid::afcov_heatmap(input$country,
                                    attribute=input$covid_measure)

    gg1

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
