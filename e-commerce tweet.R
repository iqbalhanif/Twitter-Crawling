install.packages("rtweet")
install.packages("httpuv")
install.packages("openssl")
install.packages("httpuv")
install.packages("TweetR")
install.packages("devtools")

library(rtweet)
library(jsonlite)
library(magrittr)
library(dplyr)
library(stringr)
library("httr")
library(httpuv)
library(openssl)
library(devtools)

##set work directory
setwd('D:/DATA/Desktop/')


##create token
twitter_token <- create_token(app = a,
  consumer_key = b,
  consumer_secret = c,
  access_token = d,
  access_secret = e)
##note: setiap token hanya mampu mengambil tweet dalam jumlah terbatas, diperlukan token tambahan jika dibutuhkan
##a,b,c,d,e disesuaikan dengan token masing2


##e-commerce keyword
keywords <- c("BLANJA OR blanjacom",
              "Blibli OR bliblidotcom OR BlibliCare",
              "Bukalapak OR bukalapak OR BukaBantuan",
              "Elevenia OR eleveniaID OR eleveniacare",
              "JD.ID OR JDid OR csjd_id",
              "Lazada OR LazadaID OR LazadaIDCare",
              "Matahari Mall OR MatahariMallCom OR MatahariMallCS",
              "Shopee OR ShopeeID OR ShopeeCare",
              "Tokopedia OR tokopedia OR TokopediaCare"
              )


##create directory for output
sapply(c("out_rds", "out_json", "out_csv"), dir.create, showWarnings=FALSE)


##looping for get tweet
for (key in keywords){
  twitter_token <- twitter_token
  message(key)
  
  #edit untuk tentukan max dan min tweet    
  twit <- search_tweets(
    key, 
    n = 18000, include_rts = TRUE,
    token = twitter_token
  )
  
  #file name output hasil crawling
  file_name <- key %>% str_replace_all("\\s+", "-") %>% str_to_lower()
  
  twit %>% 
    saveRDS(file = file.path("out_rds", paste0(file_name, ".Rds")))
  
  toJSON(rt, auto_unbox = TRUE) %>% 
    cat(file = file.path("out_json", paste0(file_name, ".json")))
  
  #create twit dataframe
  twitDf <- twit %>% 
    select(status_id:retweet_count, place_full_name)
  
  #ambil text dari twit
  twitDf$text <- twitDf$text %>%
    str_replace_all("\r|\n", " ") %>%
    str_replace("\"", "'")
  
  #ambil hasshtag dan mention dari twit
  twitDf$hastags <- sapply(twit$hashtags, paste, collapse = ",")
  twitDf$mentions_screen_name <- sapply(twit$mentions_screen_name, paste, collapse = ",")
  
  #hasil akhir
  twitDf %>%
    write.table(file = file.path("out_csv", paste0(file_name, ".csv")), 
                row.names = FALSE,
                na = "",
                sep = ",",
                append = TRUE)
}

