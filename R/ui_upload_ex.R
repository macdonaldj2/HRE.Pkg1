#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# UI STRUCTURE --- 'Upload/Download Example' MENU/TAB
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = 
#CHECK OUT https://cran.r-project.org/web/packages/downloadthis/vignettes/downloadthis.html
ui_upload_ex <- 
sidebarLayout(
  sidebarPanel(
    fileInput("file_in", 
              label = "Upload a file",
              placeholder = "Choose a csv or rds file",
              multiple = FALSE,
              accept = c(".csv", ".rds")),
    
    # add options for upload (delimiter, header, rows to skip....)
    #checkboxInput("header", "Header", TRUE)
    tags$hr(),
    radioButtons("disp", "Display",
                 choices = c(Head = "head",
                             Structure = "str"),
                 selected = "str"), 
    br(), 
    tags$hr(),
    downloadButton("dataDownload", class = "btn-block")  
    ),
  mainPanel(
    h3("Raw data"),
    verbatimTextOutput("preview1")
  )
)
# 
# ui_clean <- sidebarLayout(
#   sidebarPanel(
#     checkboxInput("snake", "Rename columns to snake case?"),
#     checkboxInput("constant", "Remove constant columns?"),
#     checkboxInput("empty", "Remove empty cols?")
#   ),
#   mainPanel(
#     h3("Cleaner data"),
#     tableOutput("preview2")
#   )
# )
# 
#  ui_download <- fluidRow(
#    column(width = 12, 
#           downloadButton("download", class = "btn-block"))
# )

 
# ui_upload_ex <- fluidPage(
#   ui_upload,
#   #ui_clean,
#   ui_download
# )

