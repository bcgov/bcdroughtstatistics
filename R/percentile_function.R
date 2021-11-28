# Copyright 2020 Province of British Columbia
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


#' @description Function for calculating the percentile from tidyhydat extracted data. Limited to current day calculation. Only calculates percentiles if there is at least 5 years of historic data. Made Aug 2020 by Ashlee Jollymore
#' @param historical_flow historical flow data from hydat database
#' @param realtime_data realtime data (from last 30 days)
#' @param expected percentile bins
#' @param number_of_years number of years of data
#' @keywords internal
#' @importFrom magrittr %>%
#' @export
#' @examples
#' @return Returns a data frame with percentiles based on historic data
#' calc_percentiles()
calc_percentiles <- function(historical_flow, realtime_data, expected, number_of_years) {
  df <- historical_flow %>%
    dplyr::filter(lubridate::yday(.data$Date) == lubridate::yday(Sys.Date())) %>%
    dplyr::group_by(.data$STATION_NUMBER) %>%
    tidyr::nest() %>%
    dplyr::left_join(realtime_data, by = c("STATION_NUMBER")) %>%
    dplyr::left_join(number_of_years, by = c("STATION_NUMBER")) %>%
    dplyr::mutate(prctile = ifelse(!is.na(Value), # if there is no data for today
                              ifelse(RECORD_LENGTH > 5, # if there is less than 5 years of data
                                ifelse(all(!is.na(data[[1]]$Value)), # if there is no data for today in historic record
                                       purrr::map2_dbl(data, Value, ~ ecdf(.x$Value)(.y)), NA), NA), NA)
    ) %>%
    dplyr::left_join(allstations, by = c("STATION_NUMBER")) %>%
    dplyr::mutate(pct_bin = case_when(
      is.na(prctile) ~ "Not ranked",
      prctile >= 0 & prctile <= 0.01 ~ "Low",
      prctile > 0.01 & prctile <= 0.10 ~ "Much below normal (<10)",
      prctile > 0.10 & prctile <= 0.24 ~ "Below Normal (10-24)",
      prctile > 0.24 & prctile <= 0.75 ~ "Normal (25-75)",
      prctile > 0.75 & prctile <= 0.90 ~ "Above normal (76-90)",
      prctile > 0.90 & prctile < 1 ~ "Much above normal (>90)",
      prctile == 1 ~ "High"
      # NEW SYSTEM *****
      #prctile >= 0 & prctile <= 0.01 ~ expected[2],
      #prctile > 0.01 & prctile <= 0.02 ~ expected[3],
      #prctile > 0.02 & prctile <= 0.05 ~ expected[4],
      #prctile > 0.05 & prctile <= 0.10 ~ expected[5],
      #prctile > 0.10 & prctile <= 0.20 ~ expected[6],
      #prctile > 0.20 & prctile <= 0.30 ~ expected[7],
      #prctile > 0.3 & prctile <= 0.75 ~ expected[8],
      #prctile > 0.75 & prctile <= 0.90 ~ expected[9],
      #prctile > 0.9 & prctile < 0.99 ~ expected[10],
      #prctile > 0.99  ~ expected[11],
    )) %>%
    dplyr::mutate(pct_bin = factor(pct_bin, levels = expected)) %>%
    dplyr::mutate(prctile = prctile * 100)
}
