#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    # browser()
    infracc %>% 
      filter(EMPRESA %in% input$empresa | length(input$empresa)==0,
             ANIO==input$anio | input$anio=='')
  })
  
  summarizedData <- reactive({
    filteredData() %>%
      group_by(DIR) %>% 
      summarise(CANT=n(),
                EMPRESAS=paste(EMPRESA[EMPRESA!=""], collapse="<br>"),
                lat=max(lat),
                long=max(long))      
    
  })
  
  empresaData <- reactive({
    filteredData() %>%
      filter(EMPRESA!="") %>%
      group_by(EMPRESA) %>% 
      summarise(CANT=n()) %>%
      arrange(desc(CANT))
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric('YlOrRd', log(summarizedData()$CANT))
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(infracc) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  # 
  # update_selection = function(data,location,session){
  #   if(is.null(data)) return(NULL)
  #   updateSelectInput(session
  #                     ,"handle_click"
  #                     ,selected=data$x_)
  # }
  
  output$histInfra <-
    renderGvis({
      gvisBarChart(empresaData()[1:5], 
                   xvar="EMPRESA", 
                   yvar="CANT")
    })

  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    # browser()
    leafletProxy("map", data = summarizedData()) %>%
      clearShapes() %>%
      addCircles(radius = 50, weight = 1, color = "#777777",
                 fillColor = ~pal(log(CANT)), fillOpacity = 0.7, popup = ~paste(EMPRESAS)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = summarizedData())

    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~log(CANT)
      )
    }
  })
  
})
