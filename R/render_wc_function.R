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

#' Function for rendering the West Coast RMarkdown product
#' @param basin The basin you want to render the drought statistics html page for
#' @param save_loc The path that you want to save a copy of the html file at. Defaults to FALSE (will not save html versio)
#' @keywords drought
#' @importFrom rmarkdown render
#' @export
#' @examples
#' @return The function returns a html version of the drought product
drought_stats_wc <- function(basin, save_loc = FALSE) {

  rmarkdown::render(paste0("inst/regional_streamflow_html.Rmd"),
                    params = list(region = basin),
                    output_file = paste0(save_loc, gsub(" ", "", basin)  ,  ".html"))
  # Save a copy for this date
  if (save_loc != FALSE) {
    file.copy(paste0(save_loc, gsub(" ", "", basin)  ,  ".html"),
            paste0(save_loc, gsub(" ", "", basin)  ,"_", Sys.Date(),  ".html"),
            overwrite = TRUE)
  }
}