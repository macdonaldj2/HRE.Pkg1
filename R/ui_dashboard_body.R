#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# UI FOR Dashboard BODY
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = =     

body <- dashboardBody(
  
  #ADD ANY CSS INFO
  #tags$head(tags$style(HTML('.box {margin: 1px; padding: 0px}'))),
  #tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  
  tabItems(
    
    # * MENU 1 - APPLICATION OVERVIEW----
    tabItem(tabName = "overview",
      p("This is a shiny app for testing setup in HRE.")
    ),
    
    # * MENU 2 - BASiC EXAMPLE ----
    tabItem(tabName = "basic-ex",
      p("This page contains a basic example for testing setup and structure of the shiny server on HRE."),
      p("How do we install required packages from CRAN?"),
    
      #source("myUI/ui_basic_ex.R", local=T)$value
      ui_basic_ex
    ),
    
    # * MENU 2 - USER PACKAGES EXAMPLES ----
    tabItem(tabName = "pkgs-ex",
      p("This page expands the basic example to allow testing the use of internal (non-cran) packages stored on a private repository"),
      p("How do we install packages stored on a private repository?"), 
      tags$ul(
        tags$li("Can I install directly from github using devtools::install_github"), 
        tags$li("Alternative could be to save a copy of gz file on server and install."), 
      )
      #source("myUI/stations_ui.R")$value
    ),
    
    # * MENU 4 - FILE uPLOAD EXAMPLE ----
    tabItem(tabName = "upload-ex",
      p("This page tests the ability for users to upload a dataset, or download formatted results and/or reports"),
      #add tab stucture -- 1 tab for upload and one tab for download
      #source("myUI/ui_upload_ex.R", local=T)$value
      ui_upload_ex
    ),
    
    #* MENU 5 - ACCESSING DATABASES   ----
    #- - - - - - - - - - - - - - - - -
    tabItem(tabName = "database-copy",
      p("This page tests the use of a copy of the database stored on the HRE server."), 
      p("It will use the WSC publically downloadable sql database as an example."),
      p("The hydat database can be downloaded using a function in the tidyhydat package. This function can also test if there is a newer version available for download."),
       p("Disadvantages of using a copy."),
       tags$ul(
         tags$li("Keeping the database up to date."),
         tags$li("Duplication of a database.")
       )
    ),

    tabItem(tabName = "database-internal",
      p("Is it possible to access and database internal to ECCC (but located on a different server) directly?")
    ),

    tabItem(tabName = "database-open",
      p("This page tests whether it is ppossible to download data stored on a publically available website."),
      p("For example, the 'canwqdata' package can be used to download data directly from ECCC's open data website into R.
       However, it currently no longer works due to restructuing of the open data site (I think)"),
      p("This might serve as a good example down the road to showcase capabilities")
    )
  
  )#end tabItems
)#end body
