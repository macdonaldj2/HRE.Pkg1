#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# SERVER SIDE CODE --- 'Upload and Download' MENU/TAB
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = 
# 
# # Upload ---------------------------------------------------------
raw <- reactive({
  #req(input$file_in$datapath)
  validate(need(input$file_in$datapath, "Please select a file to upload"))
  #delim <- if (input$delim == "") NULL else input$delim
  #vroom::vroom(input$file$datapath, delim = delim, skip = input$skip)
  
  ext <- tools::file_ext(input$file_in$datapath)
  
  out <- switch(ext, 
                "csv" =  readr::read_csv(input$file_in$datapath, show_col_types = FALSE), 
                "rds" = readr::read_rds(input$file_in$datapath, show_col_types = FALSE)
                )
    #vroom::vroom(input$file$datapath, delim = delim, skip = input$skip)
    #later add options
  
  out
  
})

output$preview1 <- renderPrint({
  req(raw())
   
  prev <- switch(input$disp,
                 "head" = head(raw()),
                "str" = str(raw()))

 prev
})

# Download -------------------------------------------------------
output$dataDownload <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    #vroom::vroom_write(tidied(), file)
    readr::write_csv(raw(), file)
  }
)



# # Clean ----------------------------------------------------------
# tidied <- reactive({
#   out <- raw()
#   if (input$snake) {
#     names(out) <- janitor::make_clean_names(names(out))
#   }
#   if (input$empty) {
#     out <- janitor::remove_empty(out, "cols")
#   }
#   if (input$constant) {
#     out <- janitor::remove_constant(out)
#   }
#   
#   out
# })
# output$preview2 <- renderTable(head(tidied(), input$rows))
# 

# 
# 
# selectInput("dataset", "Pick a dataset", ls("package:datasets")),
# tableOutput("preview"),
# downloadButton("download", "Download .tsv")
# 
# data <- reactive({
#   out <- get(input$dataset, "package:datasets")
#   if (!is.data.frame(out)) {
#     validate(paste0("'", input$dataset, "' is not a data frame"))
#   }
#   out
# })
# 
# output$preview <- renderTable({
#   head(data())
# })
# 
# output$download <- downloadHandler(
#   filename = function() {
#     paste0(input$dataset, ".tsv")
#   },
#   content = function(file) {
#     vroom::vroom_write(data(), file)
#   }
# )
# 
# 
# #report
# #https://mastering-shiny.org/action-transfer.html
