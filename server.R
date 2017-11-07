library(shiny)
library(shinythemes)
library(sqldf)
library(RColorBrewer)
library(wordcloud)
library(tm)
library(wordcloud)
library(stringi)
library(memoise)
library(highcharter)
library(sentimentr)
library(pacman)
library(XML)
library(dplyr)
library(stringr)
library(rvest)
library(audio)

#1 = reactiveValues()

Sys.setlocale(locale="C")
shinyServer(function(input, output,session) {

  
#r = reactiveValues()




      r <- reactive({
        
        withProgress({
          setProgress(message = "Sit Back and Relax while the app gets refreshed")
        ## Loading Libraries
        pacman::p_load(XML, dplyr, stringr, rvest, audio)

        ## Remove all white space
        trim <- function (x) gsub("^\\s+|\\s+$", "", x)

        ## Enter the Product Code and Change the URL as necessary
        prod_code = input$id
        print(input$url)
        a = ifelse(input$url=="one" ,"https://www.amazon.in/dp/", "https://www.amazon.in/gp/product/")
        print(a)
        url <- paste0(a, prod_code)
        doc <- read_html(url)
        print(url)

        ## Checking if the entered product ID is what we want
        prod <- html_nodes(doc, "#productTitle") %>% html_text() %>% gsub("\n", "", .) %>% trim()
        print(prod)



        ## Change Page length as required
        pages <- 10
        ############### Extraction of Reviews ###################

        ## Change Page length as required
        #pages <- 2

        ## Install and Load the libraries ("stringi" and "sentimentr") before this
        ## Again Change the URL as required
        reviews_all <- NULL
        for(page_num in 1:pages){
          url <- paste0("http://www.amazon.in/product-reviews/",prod_code,"/?pageNumber=", page_num)
          doc <- read_html(url)
          print(page_num)
          print(doc)
          tt = amazon_scraper(doc, reviewer = F, delay = 2)

          if(nrow(tt)==0)
          {
            break
          }
          else {
            reviews <- tt
            reviews_all <- rbind(reviews_all, cbind(prod, reviews))
          }
        }

        print(nrow(reviews_all))

        })
        
             
        reviews_all
          
       

      })
      
      # r = reactive({
      #   reviews_all
      #   
      # })
      # 
      
     
      output$table1 <- renderDataTable({
        
        input$Submit
        
        # Use isolate() to avoid dependency on input$obs
        reviews_all <- isolate(r())
       # reviews_all = r()
        reviews_all 
        
      })
        
        
        
        output$hcontainer <- renderHighchart({      
          
          input$Submit
          
          # Use isolate() to avoid dependency on input$obs
          tt <- isolate(r())
          
          #tt = r()
          tt1 = sqldf("select stars,count(stars) as count,count(helpful) as helpful from tt group by stars")
          
          canvasClickFunction <- JS("function(event) {Shiny.onInputChange('canvasClicked', [this.name, event.point.category]);}")
          legendClickFunction <- JS("function(event) {Shiny.onInputChange('legendClicked', this.name);}")
          
          highchart() %>% hc_title(text = "<b>Distribution of Ratings</b>",
                                   margin = 20, align = "center",
                                   style = list(color = "blue", useHTML = TRUE)) %>% 
            hc_yAxis_multiples(
              list(lineWidth = 3,title = list(text = "Frequency of Helpfullness"),min=0),
              list(showLastLabel = FALSE, opposite = TRUE,title = list(text = "Frequency of Ratings"))
            ) %>% 
            hc_xAxis(title=list(text = "Ratings"),categories = unique(tt1$stars)) %>% 
            hc_add_series(name = "Ratings", data = tt1$count,yAxis=1) %>%
            hc_add_series(name = "Helpfullness", data = tt1$helpful,type = "spline") %>% 
            # hc_add_series(name = "e", data = a$e) %>%
            hc_plotOptions(series = list(stacking = FALSE, events = list(click = canvasClickFunction, legendItemClick = legendClickFunction))) %>%
            hc_chart(type = "column")
          
        })      
        
      
        
        
        output$tablecust1 <- renderValueBox({
          
          input$Submit
          
          # Use isolate() to avoid dependency on input$obs
          #tt <- isolate(r())
          
          a =  isolate(round(mean(r()$stars),0))
          valueBox(
            value = format(a),
            subtitle = "Average Rating",
            icon = if (a >=3.5) icon("thumbs-up") else icon("thumbs-down"),
            color = if (a >= 3.5) "aqua" else "red"
          )
          
        })
        
        output$tablecust2 <- renderValueBox({
          
          
          input$Submit
          sent_agg <- isolate(with(r(), sentiment_by(comments)))
          
          
          #print(mean(sent_agg$ave_sentiment))
          a = ifelse(mean(sent_agg$ave_sentiment)<0,"Negative",ifelse(mean(sent_agg$ave_sentiment)>0 & mean(sent_agg$ave_sentiment)<0.3,"Neutral","Positive"))
          
          valueBox(
            value = format(a),
            subtitle = "Average Sentiment",
            icon = if (a >= 0.1) icon("thumbs-up") else icon("thumbs-down"),
            color = if (a >= 0.1) "aqua" else "red"
          )
          
        })
        
        getPage<-function() {
          
          input$Submit
          
          sent_agg <- isolate(with(r(), sentiment_by(comments)))
          best_reviews <- isolate(slice(r(), top_n(sent_agg, 3, ave_sentiment)$element_id))
          
          with(best_reviews, sentiment_by(comments)) %>% highlight()
          
          return(includeHTML("polarity.html"))
        }
        
        getPage1<-function() {
          
          
          input$Submit
          
          sent_agg <- isolate(with(r(), sentiment_by(comments)))
          worst_reviews <- isolate(slice(r(), top_n(sent_agg, 3, -ave_sentiment)$element_id))
          
          with(worst_reviews, sentiment_by(comments)) %>% highlight() 
          
          return(includeHTML("polarity.html"))
        }
        
        
        
        output$inc<-renderUI({getPage()})
        
        output$inc1<-renderUI({getPage1()})
        
      
      
      
      
 
    
    
  

  
 
  
  
  
  
  
  
  
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$Submit
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(r()$comments)
      })
    })
  })
 
  

  
  wordcloud_rep <- repeatable(wordcloud)
  
  
  output$cloud1  = renderPlot({
    
    
    v <-  terms()
  
    wordcloud_rep(names(v), v, scale=c(4,0.5),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
    
    
    
  })
  
  

  
  
  
  
  
})
  
  

