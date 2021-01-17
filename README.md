# africovid
Visualisation of Sub-National Covid Data for Africa

See [web interface](https://andysouth.shinyapps.io/africovidviewer/) 

Provides access to, and visualisation of, covid data collated by [Humanitarian Emergency Response Africa, HERA](https://hera-ngo.org/) and provided on the [Humanitarian Data Exchange, HDX](https://data.humdata.org/organization/hera-humanitarian-emergency-response-africa). 


Part of the [afrimapr](https://afrimapr.github.io/afrimapr.website/) project.

In early development, will change, contact Andy South with questions.


### Install africovid

Install the development version from GitHub :

    # install.packages("remotes") # if not already installed
    
    remotes::install_github("afrimapr/africovid")
    

### First Usage

``` r
library(africovid)

afcov_heatmap('Mali')
afcov_heatmap('Nigeria')

# run a shiny application allowing you to select any country
runviewer()



```
