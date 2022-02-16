#-------------------------------------------------------------------------------
# CODE DATASETS FOR PYLTM VARIABLES AND SITES
#PYLTM_raw = as pulled from envirodat database using ecwqEnvirodat::download_envirodat(); no filters
#PYLTM_clean = raw formatted with tidy column names and consistent units
#PYLTM_tidy = raw tidied with ecwqTidy (1/day, consistent units, tidy column names, ...) 
#-------------------------------------------------------------------------------

# RAW DATASET -------------------------------------------------------------
# all WQstations and variables -- will included vmvs WITHOUT paramCODE defined
# no other filters 

con <- ecwqEnvirodat::envirodat_connect()

#using all vmvs in variables instead -- even if paramCODE is NA.
#vmvs <-  ecwqData::paramCODE_to_vmv(variables$paramCODE)
vmvs <- unique(variables$vmv)

PYLTM_raw <-
  ecwqEnvirodat::download_envirodat(
    con,
    prj_nos="PYLTM",
    site_nos=unique(WQstations$SITE_NO),
    #varnames=NULL,
    #vargroups=NULL,
    vmvs=vmvs#,
    #startDate=DLstartDate, endDate=DLendDate,
    #sampletypes="1",     #must be a chr string
    #statusin=c("P", "U", "A0", "A1", "A2", "PC"),
    #flags=NULL,
    #flags= c(NA, 'D','L')  #removes DL and G
    #QAcodes=NULL,
    #LABcodes=NULL,
    #vtcodes=NULL  #Default is chr string "NULL" (include only NULLs)
  )

#write_rds(PYLTM_raw, here::here("data", "PYLTM_raw.rds"))
#---- 

# PYLTM_clean = CLEANED COPY OF DATA RAW ----------------------------------
#- similar to ecwqTidy::tidy_data but run to keep other columns from data raw
# (status, lab_code ect..)
#not yet filtered for sample_type, status, flag...
source(here::here("data-raw/fct_clean_envirodat.R"))


PYLTM_clean <- PYLTM_raw %>%
  dplyr::left_join(dplyr::select(ecwqData::stn_xref, .data$station_no, .data$PEARSEDA), by = "station_no")

PYLTM_clean <- ecwqTidy:::tidy_columns.ed_raw(PYLTM_clean, cols = c("PEARSEDA", "status", "lab_code", "method_code", "variable_group",
                                                                    "sample_type_code", "qa_code", "remarks", "meas_no", "pk", "other_sample_id"
                                                                    #value_type_code,
))


PYLTM_clean <- clean_envirodat(PYLTM_clean) %>%
  left_join(ecwqData::paramCODE_info, by="paramCODE")  %>%
  left_join(select(ecwqData::stn_xref, station_no, stnlab), by=c("SITE_NO"="station_no"))


#write_rds(PYLTM_clean, here::here("data", "PYLTM_clean.rds"))
#----

# PYLTM_tidy -- tidy dataset  ---------------------------------------------
# - ecwqTidy::tidy_data will remove any variables that don't have paramCODE defined
#but status wasn't filtere so want to remove status = 

tmp_raw <- PYLTM_raw %>% 
  #filter usually run in envirodat_download in trend workflow: 
  filter(sample_type_code == 1, #regular samples only
         status %in% c("P", "U", "A0", "A1", "A2", "PC"),  #removes "F" "PW"
         flag %in% c(NA, 'D','L')) %>%  #removes DL and G
  #additional flags also removed by above  -- "C" "ISL" "F"  
  # remove SDL when flag = D to address issues where unusually high SDL would
  # affect re-censoring below highest SDL. 
  dplyr::mutate(sample_detect_limit = case_when(flag == "D" ~ NA_real_, 
                                                TRUE ~ sample_detect_limit))


PYLTM_tidy <- ecwqTidy::tidy_data(tmp_raw,
                                  reduce_1perday=TRUE,
                                  delete_neg=FALSE,
                                  xref_cols= "Analysis_Split",
                                  messages=TRUE) %>%
  left_join(ecwqData::paramCODE_info, by="paramCODE") %>%
  left_join(select(ecwqData::stn_xref, station_no, stnlab), by=c("SITE_NO"="station_no"))  %>%
  filter(!is.na(paramCODE))

#write_rds(PYLTM_tidy, here::here("data", "PYLTM_tidy.rds"))
#----

#PYLTM_tidy  <-  readr::read_rds(here::here("data", "PYLTM_tidy.rds")) 



