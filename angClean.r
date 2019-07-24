library(tidyverse) #General purpose data wrangling
library(rvest) #Parsing of HTML/XML files
library(stringr) #String manipulation
library(rebus) #Verbose regular expressions
library(lubridate) #Eases DateTime manipulation

#okay, what are the problems with the scraped angband set?
#1)race and class occupy one column
#2)experience and turncount are comma formatted character vectors and not numerics
#3)comments is character and should just contain the number of comments
#4)updated is a character vector but should be POSIXct date

load(file = "main_df.RData") #load from the angScrape.r save's output

clean_df <- main_df

#1)split `race class`
  clean_df <- separate(clean_df, col = "race class", into = c("race", "class"), sep = " ")
  #this produces a warning about rows [2577, 3338, 4482]
  #the origin of these warning is that the dumps are inappropriate (wrong angband variant dumped as angband)
  remove_rows <- c(2577, 3338, 4482)
  clean_df <- clean_df[-remove_rows, ]

#2)convert experience and turncount into numerics
  clean_df$experience <- clean_df$experience %>%
    str_replace_all(pattern = ",", replacement = "") %>%
    as.numeric()
  clean_df$turncount <- clean_df$turncount %>%
    str_replace_all(pattern = ",", replacement = "") %>%
    as.numeric()

#3) turn comments into a numeric
  #turn empty strings into 0's, because an empty string means no comments
  clean_df$comments[which(clean_df$comments == "")] <- "0" 
  
  #replace " comments" and " comment" with "" in that order and then coerce into numeric
  clean_df$comments <- clean_df$comments %>%
    str_replace_all(pattern = " comments", replacement = "") %>%
    str_replace_all(pattern = " comment", replacement = "") %>%
    as.numeric()

#4) coerce updated column into date type.
    clean_df$updated <- dmy_hm(clean_df$updated)
    
#todo: Look for and remove cheaters (low turn count high exp, e.t.c.)
#      Look for and remove classes not in the base game (these are probably incorrect dumps)
#      Look for and remove bad version numbers (version numbers that contain letters e.t.c.)
    
save(clean_df, file = "clean_df.RData")