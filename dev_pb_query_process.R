#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This is script loads packages used for dev of target objects.
#
# By: mike gaunt, michael.gaunt@wsp.com
#
# README: [[insert brief readme here]]
#-------- [[insert brief readme here]]
#
# *please use 80 character margins
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#library set-up=================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#content in this section should be removed if in production - ok for dev
# library(gauntlet)
library(here)
library(magrittr)
library(stringr)
library(readr)
library(purrr)
library(dplyr)
library(jsonlite)

#import data====================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#manual step to send/receive data from Google drive location
#this is ran on mikes local computer

#helpful targets functions======================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#manual step to send/receive data from Google drive location

url_updates = 'http://s3.amazonaws.com/commtrans-realtime-prod/tripupdates_pb.json'
url_vp = 'http://s3.amazonaws.com/commtrans-realtime-prod/vehiclepositions_pb.json'
url_alerts = 'http://s3.amazonaws.com/commtrans-realtime-prod/alerts_pb.json'

query_rtgtfs_json = function(url, time_limit, interval) {
  temp_file = tempfile(fileext = ".csv")
  start_time = str_remove_all(Sys.time(), "[:punct:]") %>%
    str_replace_all(" ", "_")
  cat("Reading JSON data from", url, "\n")

  for (i in 1:(time_limit/interval)) {
    tryCatch({
      json_data = jsonlite::fromJSON(url, simplifyVector = T) %>%
        .[['entity']] %>%
        jsonlite::flatten() %>%
        data.frame()
      json_data_names = names(json_data)
      readr::write_csv(json_data, temp_file, append = T)
      cat("Appended data to temporary file at", Sys.time(), "\n")
    }, error = function(e) {
      cat("Error:", conditionMessage(e), "\n")
      cat("Skipping iteration", i, "\n")
    })

    Sys.sleep(interval)
  }

  cat("Query process complete. Processing JSON data...\n")
  full_queired_data = tryCatch({
    read.csv(temp_file) %>%
      set_names(json_data_names)
  }, error = function(e) {
    cat("Error while processing CSV:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(full_queired_data)) {
    saveRDS(full_queired_data, here::here("data", str_glue('data_query_{start_time}.rds')))
  } else {
    cat("Query process failed, no data to save.\n")
  }

  # delete the temporary file
  file.remove(temp_file)
}

#SECTION: Run query and process=================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# time_limit <- 3600/4 # query for 15 mins
time_limit = 60
interval = 10 # append to file every minute

hours = .5
for (i in 1:(hours*4)){
  query_rtgtfs_json(url_vp, time_limit, interval)
}

#script end=====================================================================



































