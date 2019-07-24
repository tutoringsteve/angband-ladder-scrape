library(tidyverse) #General purpose data wrangling
library(rvest) #Parsing of HTML/XML files
library(stringr) #String manipulation
library(rebus) #Verbose regular expressions
library(lubridate) #Eases DateTime manipulation

#all url's use the base url
url_base <- "http://angband.oook.cz/"

#all table url's use the stem url
url_stem <- paste0(url_base, "ladder-browse.php?v=Angband")

ang_html <- read_html(url_stem)

#obtains the number of dumps, which may change even as the scrape is run!
num_dumps <- ang_html %>%
  str_extract("Found (\\d\\d\\d\\d) dumps") %>%
  str_split(pattern = " ") %>% 
  .[[1]] %>% 
  .[2] %>%
  as.numeric()

num_pages <- floor(num_dumps / 50)

#build column names for table
column_names <- html_text(html_nodes(ang_html, "th"))
column_names[1] <- "rank"
column_names[2] <- "angband rank"
column_names[10] <- "comments"

#initialize the main capture data frame
main_df <- as.data.frame(matrix(nrow = num_dumps, ncol = length(column_names)+2))
names(main_df)[1:12]=column_names
names(main_df)[13]="links"
names(main_df)[14]="status" #winner, alive, dead

#stores all of the page urls, to be looped through to obtain the ladders
urls<- c(url_stem, paste0(url_stem, "&o=", as.character(1:num_pages)))

for(i in 1:length(urls)) {
  page_num <- i-1
  ang_html <- read_html(urls[i])
  
  #obtain the three tables on each page, the one we want is the second one.
  ang_table <- ang_html %>%
    html_nodes("table") %>%
    lapply(html_table) %>%
    .[[2]]
  
  names(ang_table) <- column_names
  
  #calculate the number of rows this page will add
  rows_to_add <- dim(ang_table)[1]
  
  #obtain all the urls to individual character dumps pages
  table_links <- ang_html %>%
    html_nodes("table") %>%
    .[[2]] %>%
    html_nodes("a") %>%
    html_attr('href')
  table_urls <- paste0(url_base, na.omit(str_extract(table_links, pattern = ".+id=\\d+")))
 
  #use the row color codes to obtain the winner/alive/dead status of each character
  status <- ang_html %>% 
    html_nodes("table") %>% 
    .[[2]] %>% 
    html_nodes("tr") %>% 
    html_attr("style") %>%
    map_chr(function(x){
      if(is.na(x)) #alive has the base background color which is not specified so is returned as NA
      {"alive"} 
      else if(x=="background-color: rgb(120,60,41)") #uniquely defines dead characters
      {"dead"} 
      else 
      {"winner"} #process of elimination leaves the winners
    })
  
  #merge the content into the main_df
  main_df[page_num*50+1:rows_to_add,1:12] <- ang_table
  main_df[page_num*50+1:rows_to_add,13] <- table_urls
  #the first value of status comes from the table headers, so drop it before assigning the rest
  main_df[page_num*50+1:rows_to_add,14] <- status[-1]
  
  #sleep a random number of seconds between 2 and 4 between each so that we are not detected as a bot
  Sys.sleep(runif(1,min=2,max=4))
  
}

save(main_df, "main_df.RData")