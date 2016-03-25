library(jsonlite)
library(dplyr)
library(magrittr)
library(data.table)
library(googleVis)

authkey <- readLines("authkey")

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

setkey(infracc, COD)

#ocupa mucho espacio esta columna, la quitamos:
infracc %<>% select(-TENOR) 

# creamos la dirección y el nombre completo:
infracc %<>% 
  mutate(
    DIR=paste0(TIPO.VIA, " ", CALLE, " ", CUADRA, "00"),
    NOM.AP=paste(CONDUCT.NOM, CONDUCT.AP)) %>%
  mutate(
    DIR=gsub("^\\s", "", use_series(.,DIR)))
    

infracc$EMPRESA %<>%
  gsub("(\\s)+(S\\.?R\\.?L\\s?\\.?|S\\.?A\\.?C?\\.?|E\\.?I\\.?R\\.?L\\.?)\\s*$","", .) %>%
  gsub("^E\\.?T\\.?\\s", "", .) %>%
  gsub("DISTRIBUCIONES", "DISTRIBUIDORA", .) %>%
  gsub("TRANSP\\.", "TRANSPORTES", .) %>%
  gsub("(\\sREAL)?\\sEXPRESS$", "", .) %>%
  sort()


# rellenamos con las latitudes y longitudes por dirección:
latlongs_r <- read.csv2("data/coordinates2.csv", as.is=T) %>% data.table %>% unique %>% extract(complete.cases(.))
infracc %<>% left_join(latlongs_r, by="DIR")
infracc %<>% filter(!is.na(long))
infracc %<>% select(DIR, lat, long, NOM.AP, EMPRESA, ANIO, MES, COD)
