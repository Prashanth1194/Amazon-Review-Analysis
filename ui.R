library(shiny)
library(shinythemes)
library(shinydashboard)
library(DT)
library(RColorBrewer)
library(wordcloud)
library(tm)
library(wordcloud)
library(stringi)
library(highcharter)
library(pacman)
library(XML)
library(dplyr)
library(stringr)
library(rvest)
library(audio)
library(sentimentr)


shinyUI(dashboardPage(skin="blue",
                      dashboardHeader(title = "Amazon Review Analysis"),
                      dashboardSidebar(
                        
                        sidebarMenu(
                          menuItem("Review Analysis", tabName = "items", icon = icon("star-o")),
                          menuItem("Most useful Review Words", tabName = "polarity", icon = icon("star-o")),
                          menuItem("Word Cloud", tabName = "cloud", icon = icon("star-o")
                                  
                                   
                                   
                                   ),
                         
                          
                        
                          
                          menuItem("About", tabName = "about", icon = icon("question-circle")),
                          menuItem("Find Me Here", icon = icon("file-code-o"), 
                                  href = "https://github.com/Prashanth1194"
                                 ),
                          
                          menuItem(
                            list(
                              textInput("id", "ID", "B0063C8B5U"),
                              #textInput("url", "URL", "https://www.amazon.in/dp/"),
                              radioButtons("url", "URL Type:",
                                           c(
                                             "https://www.amazon.in/gp/
                                              product/" = "two",
                                             "https://www.amazon.in/dp/" = "one")),
                              
                              
                              actionButton("Submit", "Submit")
                              #submitButton("Submit")
                            )
                          )
                          
                        )),
                      
                      dashboardBody(
                        tags$head(
                          tags$style(type="text/css", "select { max-width: 360px; }"),
                          tags$style(type="text/css", ".span4 { max-width: 360px; }"),
                          tags$style(type="text/css",  ".well { max-width: 360px; }")
                        ),
                        
                        
                        tabItems(  
                          tabItem(tabName = "about",
                                  h2("About this App"),
                                  
                                  HTML('<br/>'),
                                  
                                  fluidRow(
                                    box(title = "Amazon Review Analysis", background = "black", width=7, collapsible = TRUE,
                                        
                                        helpText(p(strong("1. This application allows you to quickly analyze the reviews of a particular product and have a quick glance at the most frequently used positive and negative comments"))),
                                        
                                        helpText(p("2. Enter the Product ID and select the appropriate URL option for initiating the review extaction"
                                        ))
                                        
                                      
                                        
                                        
                                        
                                        )
                                        )
                          ),
                          
                          
                          tabItem(tabName = "items",
                                  fluidRow(column(width = 6, highchartOutput("hcontainer", height = "500px")),
                                           column(width = 6, #textOutput("text"),
                                                 
                                                  box(
                                                    width = 9, status = "info", solidHead = TRUE,
                                                    title = "Average Rating and Sentiment of the Reviews",
                                                    HTML('<br/>'),
                                                    fluidRow(
                                                         valueBoxOutput("tablecust1",width =9)),
                                                    fluidRow(#HTML('<br/>'),
                                                         valueBoxOutput("tablecust2",width = 9)))
                                                  
                                                  
                                                  )),
                                   # HTML('<br/>'),
                                    
                                  fluidRow(
                                    box(DT::dataTableOutput("table1"), title = "Table of All Items", width=12, collapsible = TRUE)
                                  )
                                  ),
                          
                          
                          tabItem(tabName = "polarity",fluidRow( 
                            
                            htmlOutput("inc"),
                            HTML('<br/>'),
                            htmlOutput("inc1")
                            
                            )
                        ),
                        
                        
                        tabItem(tabName = "cloud",fluidRow( 
                          sliderInput("freq",
                                      "Minimum Frequency:",
                                      min = 1,  max = 50, value = 15),
                          sliderInput("max",
                                      "Maximum Number of Words:",
                                      min = 1,  max = 300,  value = 100),
                         
                          plotOutput("cloud1")
                          
                          
                        )
                        
                        )
                      ))))
        
        
        




