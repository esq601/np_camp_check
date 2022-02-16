suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(tidyverse)
  library(gmailr)
})

lower_pines_jul <- GET("https://www.recreation.gov/api/camps/availability/campground/232493/month?start_date=2022-06-01T00%3A00%3A00.000Z") %>%
  content() 

Sys.sleep(0.5)

lower_pines_aug <- GET("https://www.recreation.gov/api/camps/availability/campground/232493/month?start_date=2022-07-01T00%3A00%3A00.000Z") %>%
  content() 
Sys.sleep(0.5)

north_pines_jul <- GET("https://www.recreation.gov/api/camps/availability/campground/251869/month?start_date=2022-06-01T00%3A00%3A00.000Z") %>%
  content() 
Sys.sleep(0.5)

north_pines_aug <- GET("https://www.recreation.gov/api/camps/availability/campground/251869/month?start_date=2022-07-01T00%3A00%3A00.000Z") %>%
  content() 
Sys.sleep(0.5)

lp_jul <- lower_pines_jul$campsites %>%
  map_df(unlist) %>%
  pivot_longer(cols = contains("availabilities")) %>%
  mutate(camp = "Fish Creek")

lp_aug <- lower_pines_aug$campsites %>%
  map_df(unlist) %>%
  pivot_longer(cols = contains("availabilities")) %>%
  mutate(camp = "Fish Creek")

np_jul <- north_pines_jul$campsites %>%
  map_df(unlist) %>%
  pivot_longer(cols = contains("availabilities")) %>%
  mutate(camp = "Many Glacier")

np_aug <- north_pines_aug$campsites %>%
  map_df(unlist) %>%
  pivot_longer(cols = contains("availabilities")) %>%
  mutate(camp = "Many Glacier")


lpfull <- bind_rows(lp_jul,lp_aug,np_jul,np_aug) %>%
  mutate(date = as.Date(str_remove(name,"availabilities."))) %>%
  filter(value == "Available") %>%
  select(camp,loop,site,value,date) %>%
  arrange(camp,loop,site,date) %>%
  group_by(camp,loop,site) %>%
  filter(n()>1) #%>%
  #filter(date <= as.Date("2022-07-14"))
#head()
#read1 <- read_json("creds.json")

print(paste(Sys.time(),nrow(lpfull),sep = " - "))
if(nrow(lpfull) > 0 ) {
  
  gm_auth_configure(path = "~/data_science/yosimite/creds2.json")
  #gm_oauth_app()
  #lpfull <- "test"
  gm_auth(email = TRUE, cache = "~/data_science/yosimite/.secret")
  
  email <- gm_mime() %>%
    gm_to(c("julie.gt11@gmail.com","esq601@gmail.com")) %>%
    gm_subject("Glacier Availability Alert") %>%
    gm_from("esq601@gmail.com") %>%
    gm_html_body(paste0("<p>There's availability!</p><br>",htmlTable::htmlTable(lpfull)))
  
  gm_send_message(email)
}

#source("~/data_science/yosimite/rnmp_check.R")
