## server.R ##

# The server function is run once each time a user visits your app  

server <- function(input, output, session) {
  
  # Set Reactive Values -----------------------------------------------------
  
  myReactives <-  reactiveValues(
    sel_stns = NULL, #WQstations$SITE_NO[1]  #set to first station in list as default for now (NULL wasn't working)
    sel_vars = NULL
  )#end myReactives
  
  # # Check HYDAT version -----------------------------------------------------
  # # code taken from shinyhydat
  # output$onlineHYDAT <- renderText({
  #     base_url <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  #     x <- httr::GET(base_url)
  #     new_hydat <- substr(gsub(
  #         "^.*\\Hydat_sqlite3_", "",
  #         httr::content(x, "text")
  #     ), 1, 8)
  #     paste0("Available: ",as.Date(new_hydat, "%Y%m%d"))
  #     
  # })
  # 
  # output$localHYDAT <- renderText({
  #     paste0("Local: ",as.Date(as.data.frame(tidyhydat::hy_version())[,2]))
  #     
  # })
  
  
  # Source server side functions and code ----------------------------------
  #could these be turned into a function, put in R and then called in global?
  #NEED TO FIGURE OUT HOW TO DO THIS IN A PACKAGE????
  #source(file.path("myServer", "server_basic_ex.R"),  local = TRUE)$value
  #source(file.path("myServer", "server_upload_ex.R"),  local = TRUE)$value
  
  # Get selected station and variable ---------------------------------------
  
  viewStns <- unique_selectSERVER(id="sel1_WQstn", dataset = reactive({WQstations}),
                                  Col="stnlab", group.col = "PEARSEDA", returnCOL = "SITE_NO",
                                  allow_multiple = FALSE, label = "Select a station",
                                  PickerOpts = list(title = "Select a station."))
  
  #filter parameter list for selected site
  params_selStn <- eventReactive(myReactives$sel_stns, {
    req(!is.null(myReactives$sel_stns))
    filter(param_by_stn, SITE_NO==myReactives$sel_stns)
  })
  
  
  viewParams <- unique_selectSERVER(id="sel1_param", dataset = params_selStn, #reactive({param_by_stn}),
                                    Col="paramShortName", group.col = "paramGROUP", returnCOL = "paramCODE",
                                    allow_multiple = FALSE, label = "Select a variable",
                                    PickerOpts = list(title = "Select a variable."))
  
  observe({
    myReactives$sel_stns <- viewStns()
    myReactives$sel_vars <- viewParams()
  })
  
  # Filter dataset by site and variable -------------------------------------
  
  dataset1 <- reactive({
    req(!is.null(myReactives$sel_stns) & !is.null(myReactives$sel_vars))
    
    dataset_clean %>%
      filter(SITE_NO %in%  myReactives$sel_stns, 
             paramCODE %in%  myReactives$sel_vars)
  })
  
  # Plot color from radioButton ---------------------------------------------
  #can just use inputs$plotcolor
  
  
  # Call dateRangeSlider module ---------------------------------------------
  
  #returns s reactive value containing a Date vector of length 2.
  viewDates <- dateRangeSliderSERVER(id="daterange",
                                     dataset = dataset1,#reactive dataset,
                                     dateCOL = "Date",
                                     #minDate=reactive({"2000-01-01"}), 
                                     #maxDate=reactive({"2021-12-31"}),
                                     label = "Select date Range"#,
                                     #... additional optional arguments to shiny::dateRangeInput
  )
  
  #warning that need to select 1 variable-site
  # output$warntrig_2b <- renderPrint({
  #   #req(!is.null(  trendData_filteredONE()))
  #   validate_1siteparam(  trendData_filteredONE(), siteCOL="SITE_NO", paramCOL="paramShortName")
  #   paste0(myReactives$sel_params, " at ", myReactives$sel_stns)
  # })
  
  
  # GET DATASET TO PLOT -----------------------------------------------------
  
  dataset1_filt <- reactive({
    req(dataset1(), viewDates())
    
    dataset1() %>% 
      filter(Date >= viewDates()[1] & Date <= viewDates()[2])
  })
  
  
  # CREATE TABLE OUTPUT -----------------------------------------------------
  
  output$previewDT <- DT::renderDataTable({
    
    #req(!is.null(dataset1_filt()))
    
    hidecol <- c(0, 15:24)
    
    DT::datatable(
      dataset1_filt(), 
      rownames = FALSE,
      #selection = list(mode = "single"),
      filter = 'top',
      extensions = c("Scroller","ColReorder","Buttons"),
      options = list(
        columnDefs = list(list(targets=hidecol, visible=FALSE)), 
        scrollX = TRUE,
        scrollY = 450, deferRender = TRUE, scroller = TRUE,
        dom = 'Bfrtip', 
        colReorder = TRUE,
        buttons= list(list(
          extend = 'colvis', columns = hidecol), 
          #'print', 
          list(extend = 'collection', 
               buttons = c('copy', 'csv', 'excel'),
               text = 'Download'
          )))
    )
  })
  
  
  # CREATE PLOT OUTPUT ------------------------------------------------------
  
  tsplot <- reactive({
    
    req(dataset1_filt())
    
    TSplot_ggplot(dataset1_filt(),
                  show.line = TRUE,
                  color_var =  input$plotcolor)
    #title="", subtitle="", 
    #x_label="", y_label="")
  })
  
  output$tsplot1 <- renderPlot({
    req(tsplot())
    tsplot()
    
  })
  
  output$tsplotly <- renderPlotly({
    req(tsplot()) 
    
    #create pure plotly later...
    plotly::ggplotly(tsplot())# %>%
    #rangeslider(start = viewDates()[1], end = viewDates()[2])# %>%
    #layout(hovermode = "x")
  }) 
  
  # Testing -----------------------------------------------------------------
  
  output$test <- renderPrint({
    str(viewDates())
    #glimpse(dataset1())
    #str(input$plotcolor)
  })
  
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
  
  
}#END SERVER