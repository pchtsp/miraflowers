library(jsonlite)
library(dplyr)
library(magrittr)
library(data.table)
library(RgoogleMaps)

# servicios:

authkey <- readLines("authkey")

# INFRA-POR-UBICA
# PARAD-AUTOR
# FOTO-PAPEL-EMITI
# INFRA-81207
# TIPOS-DE-INFRA
# INFRA-POR-UBICA
# EMPRE-DE-TRANS-61574

GUID <- "INFRA-81207"

url_base <- "http://miraflores.cloudapi.junar.com/api/v2/datastreams/"

url <- paste0(url_base,GUID,"/data.ajson?auth_key=",authkey)

infracciones <- jsonlite::fromJSON(url)

# tratamiento inicial de datos:
infracc <- infracciones$result %>% as.data.table
infracc[] <- lapply(infracc, as.character)
names(infracc) <- infracc[1,] %>% as.vector %>% as.character
infracc <- infracc[-1,]

# les cambiamos de nombres a unos más cortos
new_names <- c("COD", "ANIO", "MES", "FECHA", "ACTA", 
               "INF", "TENOR", "SITUACION", "ANULADA", "CONDUCT.AP",
               "CONDUCT.NOM", "LICENCIA", "PLACA", "TIPO.VIA", "CALLE", 
               "CUADRA", "VEH", "RUTA", "EMPRESA", "INSPECTOR")
setnames(infracc, new_names)

#ocupa mucho espacio esta columna, la quitamos:
infracc %<>% select(-TENOR) 

infracc %<>% mutate(DIR=paste0(TIPO.VIA, " ", CALLE, " ", CUADRA, "00"))
infracc %<>% mutate(NOM.AP=paste(CONDUCT.NOM, CONDUCT.AP))
infracc$DIR <- gsub("^\\s", "", infracc$DIR)

latlongs_r <- read.csv2("data/coordinates.csv", as.is=T) %>% data.table %>% unique %>% extract(complete.cases(.))
# 
# latlongs <- t(sapply(paste0(latlongs_r$DIR,", miraflores, Lima, Perú"), getGeoCode))
# write.csv2(latlongs, file="data/coordinates2.csv")

infracc %<>% left_join(latlongs_r, by="DIR")

infracc_resumen <- 
  infracc %>%
  filter(EMPRESA!="") %>%
  group_by(EMPRESA) %>% 
  summarise(CANT=n())    