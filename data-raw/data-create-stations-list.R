#-------------------------------------------------------------------------------
# CODE USED TO CREATE STATIONS DATASETS
#-------------------------------------------------------------------------------

# Create PYLTM Station List from envirodat database -----------------------

con <- ecwqEnvirodat::envirodat_connect()

WQstations <- DBI::dbGetQuery(con, "SELECT distinct sa.station_no, st.station_name, st.station_description,
                                  sa.project_no, st.active_indicator, st.m_latitude, m_longitude
                                  FROM PESC.SAMPLES sa join ENVIRODAT.PROJECTS p on sa.project_no = p.project_no
                                  join envirodat.stations st on sa.station_no = st.station_no") %>%
  dplyr::filter(project_no == "PYLTM",
                !station_no %in% c("BC08MH0368", "BC08MH0370", "BC08CP0002", "BC08CP0000", "NW10ED0001")) %>%
  dplyr::left_join(select(ecwqData::stn_xref, station_no, BCMOE_ID,  PROV_TERR,
                          CESI, OpenData, PEARSEDA,
                          Agreement, LabGroup, Jurisdiction, DrainageArea),
                   by="station_no") %>%
  dplyr::mutate(stnlab = paste0(station_name, " (", station_no, ")")) %>%
  dplyr::rename(Latitude = m_latitude,
                Longitude = m_longitude,
                SITE_NO = station_no) %>%
  dplyr::mutate(active_indicator = dplyr::case_when(active_indicator == "Y" ~ "Active",
                                                    active_indicator =="N" ~ "Inactive",
                                                    TRUE ~ active_indicator)) %>%
  
  #add WSCsite info from WSC_xref (site and collocation info)
  dplyr::left_join(select(ecwqData::WSCstns_xref, "WQ_station_no", "WSC_station_no", "Collocated"),
                   by = c("SITE_NO" = "WQ_station_no")) %>%
  
  dplyr::select(SITE_NO, station_name, BCMOE_ID, station_desc = "station_description",
                active_indicator, PROV_TERR, PEARSEDA,
                Jurisdiction, Agreement, LabGroup,
                CESI, OpenData,
                DrainageArea,
                WSC_ID = "WSC_station_no", WSC_collocated = "Collocated",
                Latitude, Longitude,
                stnlab
  )

#saveRDS(WQstations, here::here("data", "WQstations.rds"))
#----

# Create WSC stations dataset ---------------------------------------------
#get all BC and YT WSC stations from BC
WSCsites <- tidyhydat::hy_stations(prov_terr_state_loc = c("BC", "YT")) %>%
  left_join(tidyhydat::hy_agency_list(), by = c("CONTRIBUTOR_ID" = "AGENCY_ID")) %>% rename("CONTRIBUTOR"=AGENCY_EN) %>%
  left_join(tidyhydat::hy_agency_list(), by = c("OPERATOR_ID" = "AGENCY_ID")) %>%  rename("OPERATOR"=AGENCY_EN) %>%
  #left_join(hy_datum_list(), by = c("DATUM_ID" = "DATUM_ID")) %>% rename("DATUM"=DATUM_EN) %>%
  mutate(REGIONAL_OFFICE_ID = as.integer(REGIONAL_OFFICE_ID)) %>%
  left_join(tidyhydat::hy_reg_office_list(), by = c("REGIONAL_OFFICE_ID" = "REGIONAL_OFFICE_ID")) %>% rename("REGIONAL_OFFICE"=REGIONAL_OFFICE_NAME_EN) %>%
  left_join(tidyhydat::hy_stn_regulation(), by="STATION_NUMBER") %>%
  select(STATION_NUMBER,STATION_NAME,PROV_TERR_STATE_LOC,HYD_STATUS,LATITUDE,LONGITUDE,DRAINAGE_AREA_GROSS,RHBN,
         REAL_TIME,REGULATED, OPERATOR,REGIONAL_OFFICE, CONTRIBUTOR)

WSC.params <- tidyhydat::hy_stn_data_range() %>% filter(DATA_TYPE=="Q"|DATA_TYPE=="H")  %>%
  select(STATION_NUMBER,DATA_TYPE) %>% tidyr::spread(DATA_TYPE,DATA_TYPE) %>%
  mutate(PARAMETER=ifelse(is.na(H),"Flow",ifelse(is.na(Q),"Level",paste("Flow and Level")))) %>%
  select(STATION_NUMBER,PARAMETER)

WSCsites  <- left_join(WSCsites,WSC.params, by="STATION_NUMBER") %>%
  rename("PROV_TERR"=PROV_TERR_STATE_LOC)

#saveRDS(WSCsites , here::here("data", "WSCsites.rds"))
#----