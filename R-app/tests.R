library(jsonlite)
library(dplyr)
library(magrittr)
library(data.table)

GUID <- "INFRA-81207"

url_base <- "http://miraflores.cloudapi.junar.com/api/v2/datastreams/"

url <- paste0(url_base,GUID,"/data.ajson?auth_key=",authkey)

infracciones <- jsonlite::fromJSON(url)

infracc <- infracciones$result %>% as.data.table
infracc[] <- lapply(infracc, as.character)
names(infracc) <- infracc[1,] %>% as.vector %>% as.character
infracc <- infracc[-1,]

