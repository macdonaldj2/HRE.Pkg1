# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# MODULE FOR SELECTING FROM UNIQUE VALUES OF A COLUMN IN A DATASET
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

#install.packages("shinyWidgets")
#devtools::install_github("dreamRs/shinyWidgets")

# Module UI function ------------------------------------------------------

#' unique_selectUI: Module UI function
#'
#' The UI for a dropdown list (using shinyWidgets::pickerInput).  The drop down
#' options are the unique values from the selected column of a dataframe.
#' Includes two buttons to the top of the dropdown menu (Select All & Deselect
#' All).
#'
#' @param id The namespace for the module
#'
#' @export
#'
unique_selectUI <- function(id){
  
  # Create a namespace function using the provided id.
  #All UI function bodies should start with this line
  ns <- NS(id)
  
  uiOutput(ns("selUnique_UI"))
}


# Module Server logic function --------------------------------------------

#' unique_select: Module Server Logic Function
#'
#' @param id The namespace for the module
#' @param dataset A dataframe or tibble
#' @param Col The character vector of the column name in the dataset from which
#'   to select unique values
#' @param group.col (optional) A character vector used to group the Col values
#'   by in the drop down list.
#' @param label Display label for the control, or \code{NULL} for no label
#'   (default)
#' @param PickerOpts list of options to pass to
#'   \code{\link[shinyWidgets]{pickerInput}}. See
#'   \code{\link[shinyWidgets]{pickerOptions}}
#' @param allow_multiple logical indicating if multiple values can be selected
#' @param returnCOL string of the column from dataset that will be returned for
#'   selected values.  Default value is NULL; this will return the Col column.
#'   for all available options. Refer to note below on syntax.
#' @return A reactive object with selected values from the dropdown list.
#' @export
#'
#' @note PickerOpts pickerOptions must be entered as a list -- eg
#'   list(actionsBox = TRUE, title = "Please select from list")).    The
#'   following syntax also seems to work (unable to find source) - eg.
#'   list(`actions-box` = TRUE, `title` = "Please select from list")
#'
#' @importFrom purrr map
#' @importFrom tibble deframe
#' @importFrom tidyselect everything
#' @import shiny
#'
#'   
unique_selectSERVER <- function(id, dataset=NULL, 
                                Col=NULL, group.col=NULL, returnCOL=NULL,
                                label = NULL, allow_multiple = TRUE,
                                PickerOpts = list(actionsBox = TRUE, 
                                                  title =  "Please select from list")){
  
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      uniqueChoices <- shiny::reactive({
        shiny::req(!is.null(dataset()))
        
        #ColSel <- c(Col, group.col)
        x <- unique(dataset()[ c(Col, group.col, returnCOL)]) 
        x <- x %>% 
          dplyr::mutate(
            dplyr::across(everything(), ~tidyr::replace_na(.x, "Not Defined"))) 
        
        #check if NA group has any values -- if not remove as options??
        
        if(is.null(returnCOL)){
          
          if(is.null(group.col)){
            x <- tibble::deframe(x)
          }else{
            x <- purrr::map(split(x[[Col]], x[[group.col]]), as.list)
          }  
        }else{ #in returnCOL is not NULL
          
          if(is.null(group.col)){
            #x <- tibble::deframe(x)
            tibble::deframe(x[c(Col, returnCOL)])
          }else{
            #x <- split(x[[Col]], x[[group.col]])
            #x <- purrr::map(split(x[[Col]], x[[group.col]]), as.list)
            x <- purrr::map(split(tibble::deframe(x[c(Col, returnCOL)]), x[group.col]), as.list)
            
          }
        }
        
        if("Not Defined" %in% names(x)){x[c(change_first(names(x)))]}
        #x <- change_first(x)  #in utils: #put "Not Defined" first then alphabetical
        x
      }) 
      
      
      
      #UI on SERVER SIDE
      #-------------------
      #to convert to format that can be used in options below
      names(PickerOpts) <- convert_names(names(PickerOpts))
      
      output$selUnique_UI <- renderUI({
        ns <- session$ns
        
        shiny::req(!is.null(dataset()))
        
        shinyWidgets::pickerInput(
          inputId = ns("selUnique"),
          label = label,
          choices = uniqueChoices(),
          multiple = allow_multiple,
          options = PickerOpts)
        
      })
      
      return(shiny::reactive(input$selUnique))
    })
}


# Example in Shiny app ----------------------------------------------------
#
# library(shiny)
# library(shinyWidgets)
# library(tidyverse)
# 
# 
# allRESULTS <- readRDS("~/r_projects/misc-projects/ArchivedProjects/shiny-ECCCexplore/allRESULTS.rds")
# dat <- allRESULTS[["dataTIDY"]]
# 
# ui <- fluidPage(
#   unique_selectUI("select1"),
#   verbatimTextOutput("returnedVal")
# )
# 
# server <- function(input, output, session) {
# 
#    dataALL <- reactive({
#      dat
#    })
# 
#    #vars <- callModule(module=unique_select, id="select1", dataset = dataALL,
#    #                    Col="paramShortName", group.col="paramGROUP", label = "Basin", title="Select basins")
# 
#    vars <- unique_select("select1",dataset = dataALL,
#                          Col="paramShortName", group.col="paramGROUP",returnCOL = "paramAbbrev",
#                          label = "label goes here",
#                          #this doesn't work when passed as list
#                          PickerOpts = list(actionsBox = FALSE,
#                                                title = "select test"))
#                          #this different syntax also seems to work before changed code..
#                           #pickerOptions = list(`actions-box` = TRUE,
#                           #                          `title` = "Please select from list"))
# 
#   output$returnedVal <- renderPrint({
#     glimpse(vars())
#   })
# 
# }
# 
# shinyApp(ui, server)
