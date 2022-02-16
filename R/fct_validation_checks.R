# === ===  === ===  === ===  === ===  === ===  === ===  === ===  === ===  ===
# Validation checks
# === ===  === ===  === ===  === ===  === ===  === ===  === ===  === ===  ===


# check_NinCol ------------------------------------------------------------
#to check if nn elements in dataset column
#check_1inCol(df, "DecDate")

#' check if the dataset has a specific number of unique values in a column
#'
#' @param dat dataset to check
#' @param column string character of column to check
#' @param nn number of unique values you want to cehck for
#'
#' @return  True or False
#' @export


check_NinCol <- function(dat, column, nn){
  
  if(!any(colnames(dat) == column)){
    warning("Column is not in the datset")
    return(FALSE)
  }
 
  t <- length(unique(dat[[column]]))
  ifelse(t == nn, TRUE, FALSE)
  
}




# not_1siteparam ----------------------------------------------------------
#to test if only 1 site/param is selected for use with validate...
  
#' not_1siteparam
#'
#' Test if only 1 site and parameter is selected. Designed to be used with picker so that 
#' NULL means all are selected (none are filtered). Return TRUE is NULL.
#' 
#' @param sites vector of sites
#' @param params vector of strings
#'
#' @return T/F
#' @export
#'

not_1siteparam <- function(sites=NULL, params=NULL) {

  #because NULL in pickerInput means all are selected...none are filtered..
      sitetrig <- if(is.null(sites)){
        TRUE
      }else if (length(unique(sites)) > 1){
        TRUE
      }else {
        FALSE
      }
      
    paramtrig <- if(is.null(params)){
        TRUE
      }else if (length(unique(params)) > 1){
        TRUE
      }else {
        FALSE
      }
      
      if (all(sitetrig, paramtrig) | all(is.null(sites), is.null(params))) {
         "Make sure only 1 site and 1 parameter is selected."
      } else if (!sitetrig & paramtrig) {
         "Make sure only 1 parameter is selected."
      } else if (sitetrig & !paramtrig) {
        "Make sure only 1 site is selected."
      } else {
        NULL
      }
  }
  
#' validate 1_siteparam
#'
#' @param dat dataframe
#' @param siteCOL string of column containing sites
#' @param paramCOL string of column containing parameters to cehck
#'
#' @return validation check if dataset contins 1 site and 1 parameter
#' @export
#'
  validate_1siteparam <- function(dat, siteCOL="SITE_NO", paramCOL="paramShortName"){
  validate(
    need(check_NinCol(dat, siteCOL, 1),
      "Requires 1 site to be selected. Please select only one site."),
    need(check_NinCol(dat, paramCOL, 1),
      "Requires 1 variable to be selected. Please select only one variable.")
      )
  }
  
  
  

         
# validate for required columns -------------------------------------------

#' Validates if dataset is not null and all required columns exist
#'
#' @param dat dataset
#' @param req_cols column required as character vector
#'
#' @return  fgdfg
#' @export

validate_reqcol <- function(dat, req_cols){
  validate(
    need(!is.null(dat), "No input dataset."),
    need(all(req_cols %in% colnames(dat)), 
    paste0("Dataframe must have the following columns: ", glue::glue_collapse(req_cols, '", "')))
  )
}    
