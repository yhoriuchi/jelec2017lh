#' Download, merge, and wrangle municipality-level election data
#' 2017 House of Representatives Election in Japan
#' Step 1: Download files

# Initial settings --------------------------------------------------------

library(tidyverse)
library(rvest)

# Make a list of excel files to be downloaded -----------------------------

URLs <- NULL

for (i in 1:47){
  
  if (i < 10){
    pref_num <- paste0("0", i)
  } else{
    pref_num <- as.character(i)
  }

  url <- paste0("https://www.soumu.go.jp/senkyo/senkyo_s/data/shugiin48/shikuchouson_", pref_num, ".html")
  
  html <- read_html(url) %>% 
    as.character()
  
  xls <- str_extract_all(html, "\\d+.xls") %>% 
    as.data.frame() %>% 
    set_names(c("file")) %>% 
    mutate(url = paste0("https://www.soumu.go.jp/main_content/", file), 
           pref_id = i, 
           type = c("smd", "pr")) 
  
  URLs <- bind_rows(URLs, xls)
  
}

# Very minor fix: The file extention is different for Mie-ken (PR).
URLs <- URLs %>% 
  mutate(url = ifelse(url == "https://www.soumu.go.jp/main_content/000965537.xls", 
                      "https://www.soumu.go.jp/main_content/000965537.xlsx", 
                      url),
         file = ifelse(file == "000965537.xls", "000965537.xlsx", file))

# Check
URLs

# Download all files ------------------------------------------------------

smd <- URLs %>% filter(type == "smd")
pr  <- URLs %>% filter(type == "pr") 

for (i in 1:47){
  
  print(i)
  
  source1 <- smd[i, "url"]
  source2 <- pr[i, "url"]
  
  destfile1 <- paste0("downloaded/smd/", smd[i, "file"])
  destfile2 <- paste0("downloaded/pr/",  pr[i, "file"])

  download.file(source1, destfile1)
  download.file(source2, destfile2)
  
}

