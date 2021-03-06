#africovid/africovidviewer/ui.r


cran_packages <- c("shiny","leaflet","remotes")

lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))

library(shiny)
library(leaflet)
library(remotes)

library(africovid)
library(rgeoboundaries) #think maybe this shouldn't be needed but seems to cause fail on shinyapps


# could give language option for fr too
#sort(unique(dfhera$PAYS))
countries <- sort(unique(dfhera$name_en))

fluidPage(

  headerPanel('africovidviewer - subnational data'),

  # p(a("Paper here. ", href="https://wellcomeopenresearch.org/articles/5-157", target="_blank"), "There are two main Africa-wide sources of open data on the locations of > 100k hospitals and health facilities. Neither is perfect.
  #     This app allows detailed comparison to inform pandemic response and allow improvement."),

  p("Provides access to, and visualisation of, covid data collated by",
    a("Humanitarian Emergency Response Africa, HERA", href="https://hera-ngo.org/", target="_blank"),
    "and provided on the ",
    a("Humanitarian Data Exchange, HDX", href="https://data.humdata.org/organization/hera-humanitarian-emergency-response-africa", target="_blank")),

  sidebarLayout(

  sidebarPanel( width=3,

    p("active development May 2021, not all options working yet, v0.4\n"),

    #p(tags$strong("There are 2 main sources for locations of > 100k hospital and health facilities in Africa. Neither is perfect.
    #  This app allows detailed comparison to inform pandemic response and allow improvement.")),

    p("by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"),
      ": creating R building-blocks to ease use of open health data in Africa"),


    selectInput('country', 'Country', choices = countries,
                size=5, selectize=FALSE, multiple=FALSE, selected="Mali"),

    #TODO french language option here
    radioButtons('covid_measure', label = "covid measure", # h3("covid measure"),
                 choices = list("cases" = "CONTAMINES",
                                "deaths" = "DECES",
                                "recoveries" = "GUERIS",
                                "female cases" = "CONTAMINES_FEMME",
                                "male cases" = "CONTAMINES_HOMME"),
                 selected = "CONTAMINES"),

    #TODO prob need to move to server to get min&max dates for each country
    # dateRangeInput('dateRange',
    #                label = 'Date range for selected plots yyyy-mm-dd',
    #                start = Sys.Date() - 2, end = Sys.Date() + 2
    # ),


    #p("Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/africovid", target="_blank")),


    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),
    #  "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    #p("admin boundary data from ", a("geoboundaries", href="https://www.geoboundaries.org/", target="_blank")),

    p(tags$small("Disclaimer : Data used by afrimapr are sourced from published open data sets. We provide no guarantee of accuracy.")),

  ),

  mainPanel(

    #when just had the map
    #leafletOutput("serve_healthsites_map", height=1000)

    #tabs
    tabsetPanel(type = "tabs",
                tabPanel("heat map", plotOutput("plot_heatmap", height=600)),
                tabPanel("map latest", plotOutput("plot_map_latest", height=600)),
                tabPanel("map latest 6 days", plotOutput("plot_map_last6", height=600)),
                tabPanel("raw data", DT::dataTableOutput("table_raw"))
                #tabPanel("WHO data", DT::dataTableOutput("table_raw_who"))
                #tabPanel("about", NULL)
    )
  )
)
)


# navbarPage("healthsites in Africa, from healthsites.io and WHO", id="main",
#            tabPanel("map", leafletOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("map", mapviewOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("Data", DT::dataTableOutput("data")),
#            #tabPanel("Read Me",includeMarkdown("readme.md")))
