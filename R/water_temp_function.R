# Copyright 2021 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# =====================

#' Get water temperatures from WSC
#' @description Function for getting stream and lake temperatures from the WS sites
#' @param station_wt Stations that you want to calculate drought-relevant statistics for. Function will also retrieve data itself
#' @keywords water temperature functions
#' @export
#' @examples \dontrun{}
#' @return Returns the temperature data for sites retrieved from tidyhydat.ws

water_temp <- function(station_wt) {
  # ======================
  # Add in the temperature
  temp_station_initial <- tidyhydat.ws::realtime_ws(
    station_number = station_wt,
    token = tidyhydat.ws::token_ws(),
    parameters = 5
  ) %>%
    dplyr::filter(Code == "TW") %>%
    dplyr::filter(Value < 90) # filter for only those values under 90 deg c

  # Calculate the daily statistics
  temp_station <- temp_station_initial %>%
    dplyr::mutate(date_dmy = as.Date(Date)) %>%
    dplyr::filter(date_dmy %in% c(seq(as.Date(Sys.Date()) - 6, as.Date(Sys.Date()), by = "day"))) %>%
    # filter for the last seven days of data from today's date
    dplyr::group_by(STATION_NUMBER, date_dmy) %>%
    dplyr::summarise(
      max_daily_temp = round(max(Value, na.rm = TRUE), digits = 2),
      mean_daily_temp = round(mean(Value, na.rm = TRUE), digits = 2),
      min_daily_temp = round(min(Value, na.rm = TRUE), digits = 2)
    )

  # Calculate the mean max temp for the last 7 days for each station
  maxtemp_7daymean <- temp_station %>%
    dplyr::ungroup() %>%
    dplyr::group_by(STATION_NUMBER) %>%
    dplyr::mutate(maxtemp7daymean = round(mean(max_daily_temp, na.rm = TRUE), digits = 2)) %>%
    dplyr::select(STATION_NUMBER, maxtemp7daymean) %>%
    unique()

  # Calculate the max, min and mean temperature over the last 24 hours
  maxtemp_24hours <- temp_station_initial %>%
    dplyr::filter(Date >= Sys.time() - 60 * 60 * 24) %>%
    # get last 24 hours of data
    dplyr::group_by(STATION_NUMBER) %>%
    dplyr::mutate(maxtemp24hours = round(max(Value, na.rm = TRUE), digits = 2)) %>%
    dplyr::mutate(mintemp24hours = round(min(Value, na.rm = TRUE), digits = 2)) %>%
    dplyr::mutate(meantemp24hours = round(mean(Value, na.rm = TRUE), digits = 2)) %>%
    dplyr::select(STATION_NUMBER, maxtemp24hours, mintemp24hours, meantemp24hours) %>%
    unique()

  # Did the 23 degree C threshold get breached in the last 7 days?
  threshold_23_yn <- temp_station_initial %>%
    dplyr::mutate(date_dmy = as.Date(Date)) %>%
    dplyr::filter(date_dmy %in% c(seq(as.Date(Sys.Date()) - 6, as.Date(Sys.Date()), by = "day"))) %>%
    # filter for the last seven days of data from today's date
    # dplyr::group_by(STATION_NUMBER) %>%
    dplyr::filter(Value >= 23) %>%
    dplyr::mutate(`Was the site warmer than 23degC in the last 7 days?` = "Yes") %>%
    dplyr::mutate(Date_format = format(date_dmy, "%b %d")) %>%
    dplyr::group_by(STATION_NUMBER, `Was the site warmer than 23degC in the last 7 days?`) %>%
    dplyr::summarise(Dates_above23threshold = paste0(unique(Date_format), collapse = "; ")) %>%
    dplyr::select(STATION_NUMBER, `Was the site warmer than 23degC in the last 7 days?`, Dates_above23threshold) %>%
    unique()

  # Did the temperature exceed 20 degrees C in the last 7 days?
  threshold_20_yn <- temp_station_initial %>%
    dplyr::mutate(date_dmy = as.Date(Date)) %>%
    dplyr::filter(date_dmy %in% c(seq(as.Date(Sys.Date()) - 6, as.Date(Sys.Date()), by = "day"))) %>%
    # filter for the last seven days of data from today's date
    dplyr::filter(Value >= 20) %>%
    dplyr::mutate(`Was the site warmer than 20degC in the last 7 days?` = "Yes") %>%
    dplyr::mutate(Date_format = format(date_dmy, "%b %d")) %>%
    dplyr::group_by(STATION_NUMBER, `Was the site warmer than 20degC in the last 7 days?`) %>%
    dplyr::summarize(Dates_above20threshold = paste0(unique(Date_format), collapse = "; ")) %>%
    dplyr::select(STATION_NUMBER, `Was the site warmer than 20degC in the last 7 days?`, Dates_above20threshold) %>%
    unique()

  # Join all together
  temp_data_1 <- dplyr::full_join(maxtemp_7daymean, maxtemp_24hours)
  temp_data_2 <- dplyr::full_join(temp_data_1, threshold_23_yn)
  temp_data_3 <- dplyr::full_join(temp_data_2, threshold_20_yn) %>%
    dplyr::mutate(`Was the site warmer than 23degC in the last 7 days?` = ifelse(is.na(`Was the site warmer than 23degC in the last 7 days?`), "No", `Was the site warmer than 23degC in the last 7 days?`)) %>%
    dplyr::mutate(`Was the site warmer than 20degC in the last 7 days?` = ifelse(is.na(`Was the site warmer than 20degC in the last 7 days?`), "No", `Was the site warmer than 20degC in the last 7 days?`))

}
