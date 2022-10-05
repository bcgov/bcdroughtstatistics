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

#' calculate all drought relevant statistics for stations
#' @description Function for assembling drought statistics and data directly from tidyhydat. Initially developed Aug 2020 by Ashlee Jollymore
#' @param stations A list of stations that you want to calculate drought-relevant statistics for. Function will also retrieve data itself
#' @keywords drought stats
#' @importFrom utils data
#' @importFrom stats median
#' @importFrom methods as
#' @importFrom rlang .data
#' @export
#' @examples \dontrun{}
#' @return The function returns a dataframe of statistics for the list of stations provided
drought_statistics <- function(stations) {

  q_stns <- unique(stations) %>%
    tidyhydat::hy_stn_data_range() %>%
    dplyr::filter(.data$DATA_TYPE == "Q") %>%
    # dplyr::filter(RECORD_LENGTH >= 10) %>%
    dplyr::pull(.data$STATION_NUMBER)

  # Get the number of years of data
  q_stns_yrs <- unique(stations) %>%
    tidyhydat::hy_stn_data_range() %>%
    dplyr::filter(.data$DATA_TYPE == "Q") %>%
    dplyr::select(.data$STATION_NUMBER, .data$RECORD_LENGTH)

  # Query realtime data. Trycatch function in case
  ee <- function (i) {
    tryCatch(tidyhydat::realtime_dd(i), error = function(e) NULL)
  }

  rl_data <- do.call(dplyr::bind_rows, lapply(q_stns, ee))

  ## Find most recent instantaneous discharge value
  rl_data_instant <- rl_data %>%
    dplyr::filter(.data$Parameter == "Flow") %>%
    dplyr::group_by(.data$STATION_NUMBER) %>%
    dplyr::filter(.data$Date == max(Date)) %>%
    dplyr::select(.data$STATION_NUMBER, .data$Date, .data$Value) %>%
    dplyr::mutate(Date = as.Date(.data$Date)) %>%
    dplyr::filter(.data$Date == Sys.Date()) %>%
    ## drop max values that aren't today
    dplyr::ungroup() %>%
    dplyr::rename(Q_instant = .data$Value)

  ## Find the average of the last 24 hours
  rl_data_last24 <- rl_data %>%
    dplyr::filter(.data$Parameter == "Flow") %>%
    dplyr::group_by(.data$STATION_NUMBER) %>%
    dplyr::filter(.data$Date >= Sys.time() - 60 * 60 * 24) %>%
    ## all data from last 24 hours
    dplyr::select(.data$STATION_NUMBER, .data$Date, .data$Value) %>%
    dplyr::mutate(Date = Sys.Date()) %>%
    ## label last twenty four hours as from today
    dplyr::group_by(.data$STATION_NUMBER, .data$Date) %>%
    dplyr::summarise(Mean_last24 = mean(.data$Value, na.rm = TRUE)) %>%
    dplyr::ungroup()

  ## Query historical data
  ## NOTE: Should this be done with rl_data_recent$STATION_NUMBER?
  hist_flow <- tidyhydat::hy_daily_flows(q_stns)

  ## Realtime 7 day average
  ## I took the realtime daily averages
  rl_data_7day_mean <- rl_data %>%
    dplyr::filter(Parameter == "Flow") %>%
    dplyr::mutate(Date = as.Date(Date)) %>%
    dplyr::group_by(STATION_NUMBER, Date) %>%
    dplyr::summarise(MeanDailyQ = mean(Value, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(STATION_NUMBER) %>%
    dplyr::mutate(Q_7day = zoo::rollapply(MeanDailyQ, 7, align = "right", fill = NA, mean, na.rm = TRUE, partial = TRUE)) %>%
    dplyr::filter(Date == Sys.Date()) %>%
    dplyr::ungroup()

  # Historic 7 day average
  hist_flow_7day_mean <- hist_flow %>%
    dplyr::group_by(STATION_NUMBER, Date) %>%
    # some values in the historic record with multime values for one day
    dplyr::summarise(MeanDailyQ = mean(Value, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(STATION_NUMBER) %>%
    dplyr::mutate(Q_7day = zoo::rollapply(MeanDailyQ, 7, align = "right", fill = NA, mean, na.rm = TRUE, partial = TRUE)) %>%
    dplyr::ungroup()

  ## Expected NAWW percentile bins
  expected <- c("Not ranked", "Low", "Much below normal (<10)",
     "Below Normal (10-24)", "Normal (25-75)",
     "Above normal (76-90)", "Much above normal (>90)", "High")

  ## Calculate instantaneous percentiles
  pct_flow_instant <- bcdroughtstatistics::calc_percentiles(
    historical_flow = hist_flow,
    realtime_data = rl_data_instant %>% dplyr::rename(Value = Q_instant),
    expected,
    number_of_years = q_stns_yrs) %>%
    dplyr::rename(Q_instant = Value, prctile_inst = prctile, pct_bin_inst = pct_bin)

  ## Calculate 24 hours percentiles
  pct_flow_last24 <- bcdroughtstatistics::calc_percentiles(
    historical_flow = hist_flow,
    realtime_data = rl_data_last24 %>% dplyr::rename(Value = Mean_last24),
    expected,
    number_of_years = q_stns_yrs
  ) %>%
    dplyr::rename(Q_24hours = Value, prctile_24hours = prctile, pct_bin_24hours = pct_bin)

  # Calculate 7 day mean percentiles
  pct_flow_7day_mean <- bcdroughtstatistics::calc_percentiles(
    historical_flow = hist_flow_7day_mean %>% dplyr::rename(Value = Q_7day),
    realtime_data = rl_data_7day_mean %>% dplyr::rename(Value = Q_7day) %>% dplyr::filter(Date == Sys.Date()),
    expected,
    number_of_years = q_stns_yrs
  ) %>%
    dplyr::rename(pct_bin_7day = pct_bin) %>%
    dplyr::rename(`%tile-7day_mean` = prctile, Q_7day = Value)

  num_year_data <- tidyhydat::hy_stn_data_range(unique(pct_flow_instant$STATION_NUMBER)) %>%
    dplyr::filter(DATA_TYPE == "Q") %>%
    dplyr::select(STATION_NUMBER, RECORD_LENGTH) %>%
    dplyr::rename(`Record Length` = RECORD_LENGTH)

  ## Grab only the latest flow and merge into one data frame
  pct_flow_instant_tbl_data <- pct_flow_instant %>%
    # st_set_geometry(NULL) %>%
    dplyr::select(STATION_NAME, STATION_NUMBER, Q_instant, prctile_inst, LATITUDE, LONGITUDE) %>%
    dplyr::rename(`%tile-instant` = prctile_inst, `Instant Q` = Q_instant) %>%
    dplyr::select(-`%tile-instant`) %>%
    ## remove instant %tile
    dplyr::full_join(pct_flow_last24 %>%
      # st_set_geometry(NULL) %>%
      dplyr::select(Q_24hours, prctile_24hours, pct_bin_24hours) %>%
      dplyr::rename(`%tile-last24` = prctile_24hours)) %>%
    dplyr::full_join(pct_flow_7day_mean %>%
      # st_set_geometry(NULL) %>%
      dplyr::filter(Date == Sys.Date()) %>%
      dplyr::select(`%tile-7day_mean`, pct_bin_7day, Q_7day)) %>%
    dplyr::left_join(num_year_data, by = c("STATION_NUMBER")) %>%
    dplyr::arrange(STATION_NUMBER) %>%
    # Add in regulation status
    dplyr::full_join(tidyhydat::hy_stn_regulation(station_number = q_stns) %>%
      dplyr::mutate(regulation = ifelse(REGULATED == "TRUE", "Regulated", "Natural")) %>%
      dplyr::select(STATION_NUMBER, regulation)) %>%
    ## Add in % median and mean flow
    dplyr::full_join(hist_flow_7day_mean %>%
      dplyr::mutate(day_month = paste0(lubridate::day(Date), "-", lubridate::month(Date))) %>%
      dplyr::filter(day_month == paste0(lubridate::day(Sys.Date()), "-", lubridate::month(Sys.Date()))) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::summarize(
        mean_Q7_forthisdate = round(mean(Q_7day, na.rm = TRUE), digits = 2),
        median_Q7_forthisdate = round(median(Q_7day, na.rm = TRUE), digits = 2)
      )) %>%
    dplyr::mutate(
      Per_Q7_median = round(Q_7day / median_Q7_forthisdate * 100, digits = 0),
      Per_Q7_mean = round(Q_7day / mean_Q7_forthisdate * 100, digits = 0)
    ) %>%
    # Add in watershed area
    dplyr::full_join(hy_stations(station_number = q_stns) %>%
      as.list() %>%
      dplyr::bind_rows() %>%
      dplyr::select(STATION_NUMBER, STATION_NAME, DRAINAGE_AREA_GROSS) %>%
      dplyr::rename(basin_area = DRAINAGE_AREA_GROSS))

  # ======================
  # Add in the temperature using the water_temp() function. Do for all stations, not just those with a discharge (i.e., lakes)
  temp_data_all <- bcdroughtstatistics::water_temp(station_wt = stations)

  # Join to main data
  pct_flow_temp <- dplyr::full_join(pct_flow_instant_tbl_data, temp_data_all) %>%
    # Add in value of Q7
    dplyr::full_join(data.frame(pct_flow_7day_mean %>%
      dplyr::filter(Date == Sys.Date()) %>%
      dplyr::select(STATION_NUMBER, Date, Q_7day, `%tile-7day_mean`, STATION_NAME) %>%
      dplyr::rename(Q7_value = Q_7day, Q7_prctile = `%tile-7day_mean`))) %>%
    # Add in the Q min 7 day value for today's date
    dplyr::full_join(hist_flow_7day_mean %>%
      dplyr::mutate(day_month = paste0(lubridate::day(Date), "-", lubridate::month(Date))) %>%
      dplyr::filter(day_month == paste0(lubridate::day(Sys.Date()), "-", lubridate::month(Sys.Date()))) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::summarize(min_Q7 = round(min(Q_7day, na.rm = TRUE), digits = 2))) %>%
    # Add in MAD: only stations with at least 5 years of historic data
    dplyr::full_join(fasstr::calc_longterm_mean(
      station_number = c(unique(stations) %>%
        tidyhydat::hy_stn_data_range() %>%
        dplyr::filter(DATA_TYPE == "Q") %>%
        dplyr::filter(RECORD_LENGTH >= 5) %>%
        dplyr::pull(STATION_NUMBER)),
      complete_years = TRUE
    )) %>%
    dplyr::rename(`MAD (m^3/s)` = LTMAD) %>%
    dplyr::left_join(rl_data_7day_mean) %>%
    dplyr::mutate(`% MAD` = round((Q_7day / `MAD (m^3/s)`) * 100, digits = 2)) %>%
    dplyr::mutate(`% MAD_Q_24hours` = round((Q_24hours / `MAD (m^3/s)`) * 100, digits = 2)) %>%
    dplyr::left_join(allstations[, 1:2]) %>%
    dplyr::arrange(STATION_NUMBER) %>%
    # Add in the % MAD categories - as per the RFC website
    dplyr::mutate(MAD_bin = case_when(
      is.na(`% MAD`) ~ "Not ranked",
      `% MAD` < 1 ~ "<1%",
      `% MAD` >= 1 & `% MAD` < 5 ~ "1 to 5%",
      `% MAD` >= 5 & `% MAD` < 10 ~ "5 to 10%",
      `% MAD` >= 10 & `% MAD` < 20 ~ "10 to 20%",
      `% MAD` >= 20 & `% MAD` <= 100 ~ "20 to 100%",
      `% MAD` > 100 ~ "> 100%"
    )) %>%
    dplyr::mutate(MAD_bin_q24 = case_when(
      is.na(`% MAD_Q_24hours`) ~ "Not ranked",
      `% MAD_Q_24hours` < 1 ~ "<1%",
      `% MAD_Q_24hours` >= 1 & `% MAD_Q_24hours` < 5 ~ "1 to 5%",
      `% MAD_Q_24hours` >= 5 & `% MAD_Q_24hours` < 10 ~ "5 to 10%",
      `% MAD_Q_24hours` >= 10 & `% MAD_Q_24hours` < 20 ~ "10 to 20%",
      `% MAD_Q_24hours` >= 20 & `% MAD_Q_24hours` <= 100 ~ "20 to 100%",
      `% MAD_Q_24hours` > 100 ~ "> 100%"
    ))

  # Add in any missing station names
  stations_mnames <- pct_flow_temp %>%
    dplyr::filter(is.na(STATION_NAME))

  # desc
  dec_miss <- allstations %>%
    dplyr::filter(STATION_NUMBER %in% stations_mnames$STATION_NUMBER) %>%
    dplyr::select(-REAL_TIME, -station_tz, -standard_offset, -OlsonName, -HYD_STATUS, -PROV_TERR_STATE_LOC)

  # Get the descriptive data
  stations_missing <- dplyr::full_join(stations_mnames %>% dplyr::select(-.data$LATITUDE, -.data$LONGITUDE, -.data$STATION_NAME), dec_miss, by = "STATION_NUMBER")

  table_out <- pct_flow_temp %>%
    dplyr::filter(!is.na(STATION_NAME)) %>%
    # Merge back with stations that only have temp data - not discharge (LAKES)
    dplyr::full_join(stations_missing) %>%
  # Assemble table of drought - relevant meta data and statistics
    dplyr::select(-`%tile-7day_mean`) %>%
    dplyr::arrange(`%tile-last24`) %>%
    dplyr::rename(
      `Last 24 hour Q (m3/s)` = Q_24hours,
      `Latest 7 Day Q (m3/s)` = Q7_value,
      `Percentile - Last 24 Hour Q` = `%tile-last24`,
      `ID` = STATION_NUMBER,
      `Station Name` = STATION_NAME,
      `Historic Min 7 Day Q (m3/s)` = min_Q7,
      `Mean max temp from last 7 days (degC)` = maxtemp7daymean,
      `Max temp over last 24 hours (degC)` = maxtemp24hours,
      `Min temp over last 24 hours (degC)` = mintemp24hours,
      `Mean temp over last 24 hours (degC)` = meantemp24hours,
      `Dates above 23 degC in last 7 days` = Dates_above23threshold,
      `Dates above 20 degC in last 7 days` = Dates_above20threshold,
      `Record Length` = `Record Length`,
      `Percentile - Q7` = Q7_prctile,
      `Historic Mean Q7 for today` = mean_Q7_forthisdate,
      `Historic Median Q7 for today` = median_Q7_forthisdate,
      `Percent of Daily Median Q7 (%)` = Per_Q7_median,
      `Percent of Daily Mean Q7 (%)` = Per_Q7_mean,
      `Basin Area (km2)` = basin_area,
      `Regulation Status` = regulation
    ) %>%
    dplyr::mutate(`Percent of Daily Mean Q7 (%; Historic Mean Q7 in m3/s)` = paste0(`Percent of Daily Mean Q7 (%)`, " (", `Historic Mean Q7 for today`, ")")) %>%
    dplyr::mutate(`Percent of Daily Median Q7 (%; Historic Median Q7 in m3/s)` = paste0(`Percent of Daily Median Q7 (%)`, " (", `Historic Mean Q7 for today`, ")")) %>%
    dplyr::select(-`Percent of Daily Mean Q7 (%)`, -`Historic Mean Q7 for today`, -`Percent of Daily Median Q7 (%)`, -`Historic Median Q7 for today`) %>%
    dplyr::select(
      `Station Name`, `ID`, `Record Length`, `Basin Area (km2)`, `Regulation Status`, `LATITUDE`, `LONGITUDE`,
      `Last 24 hour Q (m3/s)`, `Percentile - Last 24 Hour Q`, pct_bin_24hours,
      `Latest 7 Day Q (m3/s)`, `Percentile - Q7`, pct_bin_7day,
      `Percent of Daily Mean Q7 (%; Historic Mean Q7 in m3/s)`,
      `Percent of Daily Median Q7 (%; Historic Median Q7 in m3/s)`,
      `Historic Min 7 Day Q (m3/s)`,
      `MAD (m^3/s)`, `% MAD`, MAD_bin, MAD_bin_q24,
      `% MAD_Q_24hours`,
      `Mean max temp from last 7 days (degC)`, `Max temp over last 24 hours (degC)`,
      `Min temp over last 24 hours (degC)`, `Mean temp over last 24 hours (degC)`,
      `Dates above 23 degC in last 7 days`, `Dates above 20 degC in last 7 days`,
      `Date`
    )
}
