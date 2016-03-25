#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(RColorBrewer)

# Define UI for application that draws a histogram
bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(
    top = 10, right = 10,
    # sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
    #             value = range(quakes$mag), step = 0.1
    # ),
    selectInput("empresa", "Empresa", multiple=T,
                unique(infracc$EMPRESA)
    ),
    selectInput("anio", "Año",
                unique(infracc$ANIO)
    ),
    checkboxInput("legend", "Show legend", TRUE),
    htmlOutput("histInfra")
    # plotOutput("histInfra", height = 200)
    #plotOutput("scatterCollegeIncome", height = 250)
    )
)
