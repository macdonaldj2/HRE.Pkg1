#= = = = = = = = = = = = = = = = = == = = = = = = = = = = = = = = = = = = = = 
# UI FOR Dashboard Sidebar 
#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = =  

sidebar <- dashboardSidebar(width = 300,
                            
                            sidebarMenu(
                              id = "sidebar1",
                              
                              menuItem(
                                "Application Overview",
                                tabName = "overview",
                                icon = icon("tint")
                              ),
                              
                              menuItem(
                                "1. Basic Example",
                                tabName = "basic-ex", 
                                icon = icon("chart-line")
                              ),
                              
                              
                              menuItem(
                                "2. Using Internal Packages",
                                tabName = "pkgs-ex", 
                                icon = icon("box-open")
                              ),
                              
                              menuItem(
                                 "3. File Upload/Download",
                                 tabName = "upload-ex", 
                                 icon = icon("upload")
                              ),
                              
                              menuItem(
                                "4. Accessing Databases",
                                icon = icon("database"),
                                startExpanded = TRUE,
                                menuSubItem("Downloaded copy", tabName = "database-copy"),
                                menuSubItem("ECCC Internal", tabName = "database-internal"),
                                menuSubItem("Open Data website", tabName = "database-open")
                              )
                             
                            ) #end sidebarMenu
                            
                            #show hydat version installed
                            #fluidPage(
                            #  br(),
                            #  hr(),
                            #  h4("HYDAT versions:"),
                            #  textOutput("localHYDAT"),
                            #  textOutput("onlineHYDAT"),
                            #  br(),br()
                            #)
                            
)#end sidebar