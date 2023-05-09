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
library(gauntlet)
library(here)

pkgs = c("tidyverse", "gauntlet", 'jsonlite', 'mapview', 'sf')

gauntlet::package_load(pkgs)

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

  start_time = gauntlet::strg_clean_datetime()

  cat("Reading JSON data from", url, "\n")

  for (i in 1:(time_limit/interval)) {
    json_data = jsonlite::fromJSON(url, simplifyVector = T) %>%
      .[['entity']] %>%
      jsonlite::flatten() %>%
      data.frame()

    json_data_names = names(json_data)

    readr::write_csv(json_data, temp_file, append = T)

    cat("Appended data to temporary file at", Sys.time(), "\n")

    Sys.sleep(interval)
  }

  cat("Query process complete. Processing JSON data...\n")

  full_queired_data = read.csv(temp_file) %>%
    set_names(json_data_names)

  saveRDS(full_queired_data, here::here("data", str_glue('data_query_{start_time}.rds')))

  # delete the temporary file
  file.remove(temp_file)
}

#SECTION: Run query and process=================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

time_limit <- 3600/4 # query for 15 mins
# time_limit = 10
interval = 10 # append to file every minute

hours = .5
for (i in 1:(hours*4)){
  query_rtgtfs_json(url_vp, time_limit, interval)
}

# lubridate::as_datetime(1683659807)
# lubridate::as_datetime(1683660726)
#
# saverd
#
# temp_data %>%
#   saveRDS("temp_rds")
#
#
# colnames(temp_data) = names(json_data)
#
# temp_data %>%
#   filter(vehicle.vehicle.id == "11102") %>%
#   select(vehicle.vehicle.id, vehicle.position.latitude, vehicle.position.longitude, vehicle.timestamp, vehi)
#
#
# 1683571601
#
# temp_data %>%
#   glimpse()
#
#
# library(sf)
#
# temp_data %>%
#   # filter(str_detect(id, "_15109")) %>%
#   # filter(vehicle.timestamp == 1683572554) %>%
#   filter(vehicle.trip.route_id == 101) %>%
#   filter(vehicle.current_status == "IN_TRANSIT_TO") %>%
#   arrange(vehicle.trip.route_id, vehicle.vehicle.id, id) %>%
#   group_by(vehicle.trip.route_id, vehicle.vehicle.id, vehicle.trip.trip_id) %>%
#   mutate(date_time = #gsub('_.*', "\\1", 1683572554)
#          vehicle.timestamp %>%
#            as.numeric() %>%
#            lubridate::as_datetime() %>%
#            lubridate::with_tz("US/Pacific")) %>%
#   mutate(datetime_diff = as.numeric(date_time-lag(date_time))) %>%
#   ungroup() %>%
#   data.frame() %>%
#   filter(datetime_diff != 0) %>%
#   sf::st_as_sf(coords = c('vehicle.position.longitude', 'vehicle.position.latitude'), crs = 4326) %>%
#   sf::st_transform(32610) %>%
#   gauntlet::st_extract_coords() %>%
#   group_by(vehicle.trip.route_id, vehicle.vehicle.id, vehicle.trip.trip_id) %>%
#   mutate(lon_diff = lon-lag(lon)
#          ,lat_diff = lat-lag(lat)
#          ,ttl_diff = sqrt(lon_diff**2 + lat_diff**2)
#          ,speed_avg = (ttl_diff/datetime_diff)*2.236936) %>%
#   ungroup() %>%
#   sf::st_transform(4326) %>%
#   st_jitter() %>%
#   mapview::mapview(#zcol = "vehicle.timestamp"
#                    zcol = "speed_avg")


#script end=====================================================================



































