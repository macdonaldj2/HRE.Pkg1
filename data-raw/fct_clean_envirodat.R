#function to convert metals when paramCODE is NA
convert_NAmetals <- function(x, Units, manualfix){
  
  x <- ifelse(isTRUE(manualfix), 
              ecwqTidy::convert_values(x, from=Units, to="ug/L", messages=TRUE), 
              x)
  
  return(x)                 
}




#FUNCTION TO tidy a raw envirodat dataset (so we can keep all extra columns and paramCODE that are not yet defined)
clean_envirodat <- function(x){
  
  #some code pulled from ecwqTidy:::tidy_columns.ed_raw
  xx <- x %>% 
    #fix_mdl() %>%  #NO RUNNING BECAUSE WANT TO KEEP IN RAW FORMAT
    dplyr::mutate(VMV=as.numeric(.data$VMV)) %>%   
    dplyr::filter(.data$Value > -999) %>% #OK - I don't need to see these...
    #adds paramCODES and converts units...
    
    #standardize_wqdata(xref_cols=xref_cols, delete_neg=delete_neg, messages=messages)
    #a - standardize_variables(x, xref_cols=xref_cols, messages=messages)
    # -- add paramCODE but don't remove those with is.na()
    dplyr::left_join(ecwqData::vmv_xref[, c("Analysis_Split", "paramCODE", "vmv")],  by = c("VMV" = "vmv")) %>%
    dplyr::distinct() 
  #dplyr::filter(!is.na(.data$paramCODE)) # -- NO BECAUSE WANT ALL RAW IN TIDY FORMAT
  
  #delete_rows_with_certain_values -- not run
  
  #b - standardize units
  #when paramCODE is NA -- won't convert_values.
  #note: issues also because salinity has some units - NA --- DL, Value get changed to NA...need to fix in database...
  cat("Running regular ecwqTidy::standardize_units_variable", "\n")
  xx  <- plyr::ddply(xx , .variables = "paramCODE",
                     .fun = ecwqTidy::standardize_units_variable, messages = TRUE)
  
  #need to add another convert units to fix those with no paramCODE
  #check1 <- filter(xx, is.na(paramCODE)) %>% group_by(variable_group, Variable, Units) %>% summarize(n=n())
  #only units in check1: "MG/L"  "UG/L"  "% SAT"
  cat("Convert Units when paramCODE is NA", "\n")
  zz <- xx %>% 
    mutate(Units = case_when(Units=="MG/L" ~ "mg/L",
                             Units=="UG/L" ~ "ug/L",
                             Units=="% SAT" ~ "%sat",
                             TRUE ~ Units)) %>%
    
    #then need to convert_units for anything is.na(paramCODE) that was ignored above
    #manually checks and it looks like everything is OK EXCEPT metals
    mutate(manualfix = case_when(is.na(.data$paramCODE) & 
                                   .data$variable_group %in% c("METALS, DISSOLVED", "METALS, TOTAL", "METALS, EXTRACTABLE") ~ TRUE,
                                 TRUE ~ FALSE)) %>%
    mutate(Value = pmap_dbl(.l=list(Value, Units, manualfix), convert_NAmetals), 
           DetectionLimit = pmap_dbl(.l=list(DetectionLimit, Units, manualfix), convert_NAmetals), 
           Units = case_when(
             is.na(.data$paramCODE) & .data$variable_group %in% c("METALS, DISSOLVED", "METALS, TOTAL", "METALS, EXTRACTABLE") ~ "ug/L", 
             TRUE ~ Units)) %>%
    
    
    dplyr::mutate(
      Date = lubridate::as_date(.data$DateTime),
      cenType = ecwqTidy::make_censor(.data$ResultLetter, makeTF = FALSE),   
      cenTF = ecwqTidy::make_censor(.data$ResultLetter, makeTF = TRUE))   
  
  #NOPE - want RAW data
  #if(reduce_1perday){out <- out %>% reduce_1perGrp(grps = c("SITE_NO", "paramCODE", xref_cols, "Date"))""
  
  return(zz)
}