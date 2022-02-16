
# PACKAGES THAT REQUIRE LOADING FOR THIS SHINY APP ------------------------

packages_to_install <- c("shiny", 
                         "plotly", 
                         "shinydashboard", 
                         #"tidyhydat", 
                         "tidyverse", #installs tibble, dplyr, tidyr, stringr, readr, forcats, purrr
                         "ggplot2",
                         #"leaflet", 
                         #"DBI", 
                         "shinyWidgets")
#   
#   # Install packages not yet installed
installed_packages <- packages_to_install  %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages_to_install[!installed_packages])
}