#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# UI STRUCTURE --- 'Basic Example' MENU/TAB
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = 

# UI Code for 'basic-ex' tab ------------------------------------
ui_basic_ex <- 

  fluidPage(
    fluidRow(
      column(width=3,
        box(title = "Options",
            solidHeader = TRUE, collapsible = TRUE, status = "primary",
            width=12,    
            unique_selectUI("sel1_WQstn"),
            unique_selectUI("sel1_param"),
             h4("Plot Options"),
            radioButtons(inputId="plotcolor",
                         label="Color:",
                         choices=c("VMV"="VMV",
                                   "Detection Limit"="DetectionLimit",
                                   "Status" = "status", 
                                    "Lab" = "lab_code", 
                                   "Method" = "method_code"),
                         selected="VMV",
                         inline=FALSE), 
            br(), 
            dateRangeSliderUI("daterange"), 
            verbatimTextOutput("test")
        )), 
      
      column(width = 9, 
             tabBox(id = "basic-out",
                    side="left", width=12, 
                    selected = "basic-tbl", 
                    tabPanel("Table", value = "basic-tbl", 
                      DT::dataTableOutput("previewDT")
                      
                      ), 
                    tabPanel("Time Series Plot", value = "basic-ts", 
                             plotOutput("tsplot1")), 
                    tabPanel("TS plotly", value = "basic-ts-plotly",
                             plotlyOutput("tsplotly")) 
                             
             )
      )

      
    )#end FR
  )#end FP


