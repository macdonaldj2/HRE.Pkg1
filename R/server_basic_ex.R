#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# SERVER SIDE CODE --- 'Basic Example' MENU/TAB
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = 

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
 
 