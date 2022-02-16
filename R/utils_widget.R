#' convert_names
#'
#' Function taken from \link[shinyWidgets]{pickerOptions}.  Used to convert names of
#' \link[shinyWidgets]{pickerOptions} options to syntax that can be used in
#' options list of \link[shinyWidgets]{pickerInput}.  
#'
#' @param x character vector
#'
#' @return a lower case character vector with dash added before any capitals in string
#' @export
#' 
#' @examples
#' \dontrun{
#' pickOpts <- list(actionBox = TURE, title = "title here")
#' names(pickOpts) <- convert_names(names(pickOpts))
#' #pickOpts can now be passed into options argument of \link[shinyWidgets]{pickerInput}
#' } 
#'
#' @note Adds dash (-) before any capital and converts to lower case.   For
#'   example actionsBox becomes actions-box
#'   
convert_names <- function(x) {
  x <- gsub(pattern = "([A-Z])", replacement = "-\\1", x = x)
  tolower(x)
}



# null_or_reactive <- function(val){
#   if(is.null(val)){val}else{val()}
# }
# val <- NULL; null_or_reactive(val)  #return NULL
# sites <- c("1", "2"); val <- shiny::reactive(sites); null_or_reactive(val) 


