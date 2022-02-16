# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# MODULE FOR DATE RANGE SLIDER 
# option to use specified min/max range for slide, or base on min/max of a dataset
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 


#' Module UI function for selecting date Range
#' 
#' @param id The namespace for the module
#'
#' @export
#' 
dateRangeSliderUI <- function(id){
  
  ns <- NS(id)
  uiOutput(ns("dates_pick"))
  
}


#' Module SERVER for for selecting date Range (dateRangeSliderUI control)
#'
#' Creates a pair of text inputs which, when clicked on, bring up calendars that
#' the user can click on to select a date range.
#'
#' The date range of the input is based either on the min/max of the input
#' dataset, or on the specified min/max dates. If the dataset argument is not
#' NULL, the min and max dates for the input control are the min and max dates
#' of this dataset.  Otherwise, the minDate and maxDate arguments are used.
#'
#' @param id The namespace for the module
#' @param dataset reactive dataframe for a dataset.  If NULL, the minDate and
#'   maxDate arguments are used to set the min/max dates allowed by the picker
#'   control;  otherwise min and max dates allowed for the control is set to the
#'   min and max dates in the dataset.
#' @dateCOL character string of the name of the date column in dataset
#' @param minDate,maxDate The minimum and maximum allowed date. Either a Date
#'   object, or a string in yyyy-mm-dd format. These arguments are ignored if
#'   dataset is not NULL.
#' @param label Display label for the control, or NULL for no label.
#' @param ... additional optional arguments to
#'   \code{\link[shiny]{dateRangeInput}}.  For example: width of input. 
#'
#' @return A reactive value containing a Date vector of length 2.
#'
#' @export
#'
#' @seealso \code{\link[shiny]{dateRangeInput}}
#'   
dateRangeSliderSERVER <- function(id, 
                                  dataset = reactive({NULL}), dateCOL=NULL,
                                  minDate = reactive({NULL}), 
                                  maxDate = reactive({NULL}), 
                                  label = NULL, 
                                  ...){
  
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      picker_range <- reactive({  #min and max dates of the picker
        if(!is.null(dataset())){
          #if dataset is not NULL get start/end dates from dataset
          dr <- c(minDate=min(dataset()[[dateCOL]], na.rm=TRUE),
                  maxDate=max(dataset()[[dateCOL]], na.rm=TRUE))
        }else{
          #get from specified inputs
          dr <- c(minDate=minDate(),
                  maxDate=maxDate())
        }
        dr
      })
      
      output$dates_pick <- renderUI({
        
        req(picker_range())
        
        shiny::dateRangeInput(inputId=ns("dates"), 
                              #start-end = initial dates
                              start = picker_range()[["minDate"]],
                              end = picker_range()[["maxDate"]],
                              #min-max = min/max allowed dates
                              #min = picker_range()[["minDate"]],
                              #max = picker_range()[["maxDate"]],
                              label = label,
                              ...
        )
        
      })
      
      return(reactive(input$dates))
      
      #return(list(start_date = reactive({input$dates[1]}), 
      #            end_date = reactive({input$dates[2]})))   
    })
}