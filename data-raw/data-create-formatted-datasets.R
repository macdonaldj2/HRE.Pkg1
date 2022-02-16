#-------------------------------------------------------------------------------
# FORMAT AND NEST DATASETS
#-------------------------------------------------------------------------------

dataset_raw <-  readr::read_rds(here::here("data", "PYLTM_raw.rds")) %>%
  mutate(Date = lubridate::as_date(sample_time), 
         decdate = lubridate::decimal_date(sample_time), 
         year = lubridate::year(Date), 
         month = lubridate::month(Date, label=TRUE, abbr=TRUE)) %>%
  rename(SITE_NO = "station_no") 

#write_rds(dataset_raw , here::here("data", "dataset_raw.rds"))


dataset_clean <-  readr::read_rds(here::here("data", "PYLTM_clean.rds")) %>%
  mutate(decdate = lubridate::decimal_date(Date), 
         year = lubridate::year(Date), 
         month = lubridate::month(Date, label=TRUE, abbr=TRUE)) %>%
  select(PEARSEDA, SITE_NO, paramShortName, Variable, VMV, 
         DateTime, Value, Units, DetectionLimit, ResultLetter, status, lab_code, method_code, 
         everything(), -manualfix)

#write_rds(dataset_clean , here::here("data", "dataset_clean.rds"))

dataset_tidy <-  readr::read_rds(here::here("data", "PYLTM_tidy.rds")) %>%
  mutate(decdate = lubridate::decimal_date(Date), 
         year = lubridate::year(Date), 
         month = lubridate::month(Date, label=TRUE, abbr=TRUE))

#write_rds(dataset_tidy , here::here("data", "dataset_tidy.rds"))

