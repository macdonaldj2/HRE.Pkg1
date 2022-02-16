#===============================================================================
# CODE TO DATASET (e.g for Rpackages data folder)
#===============================================================================

library(tidyverse)
library(ecwqData)
library(ecwqEnvirodat)
library(ecwqTidy)
library(tidyverse)

#usethis::use_data() is designed to work with packages.


# Create Station Lists --------------------------------------------

#creates WQstations and WSCsites
source(here::here("data-raw", "data-create-stations-list.R"))
usethis::use_data(WQstations, overwrite = TRUE)
usethis::use_data(WSCsitess, overwrite = TRUE)


# Create Variable and VMV list --------------------------------------------

#creates 
source(here::here("data-raw", "data-create-vmv-list.R"))
usethis::use_data(variables, overwrite = TRUE)


# Create Datasets --------------------------------------------

#creates 
source(here::here("data-raw", "data-create-datasets.R"))
#not saving to data...but needed for formatted datasets

# Create Formatted Datasets  --------------------------------------------

#creates 
source(here::here("data-raw", "data-create-formatted-datasets.R"))
usethis::use_data(dataset_raw, overwrite = TRUE)
usethis::use_data(dataset_tidy, overwrite = TRUE)
usethis::use_data(dataset_clean, overwrite = TRUE)


