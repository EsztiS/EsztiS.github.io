library(dplyr)
library(treemap)

# Reading in data and creating numeric values
receipts = read.csv('~/Documents/__NYC_DSA/Dev/EsztiS.github.io/shiny_app/data/receipts.csv', colClasses='character')
receipts = receipts %>%
  mutate_each(funs(gsub(",", "", .)), X1962:X2020) %>%
  mutate_each(funs(as.numeric(.)), X1962:X2020)

treemap(receipts,index='On..or.off.budget',vSize='X2016')

# Getting tables of code number labels
### DON'T NEED
library(RCurl)
library(RJSONIO)
url = 'https://github.com/WhiteHouse/2016-budget-data/blob/master/USER_GUIDE.md'
json_file <- "~/Documents/__NYC_DSA/Dev/EsztiS.github.io/shiny_app/data/raw.json"
download.file(url, json_file, method='curl')
proc <- fromJSON(file = json_file)

