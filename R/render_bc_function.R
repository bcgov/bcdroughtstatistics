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

#' Function for rendering the Thompson Okanagan version of the RMarkdown drought product
#' @param basin The basin you want to render the drought statistics html page for
#' @param save_loc The path that you want to save a copy of the html file at. Defaults to ''
#' @keywords drought
#' @importFrom rmarkdown render
#' @export
#' @examples
#' @return The function returns a html version of the drought product
render_function_bc <- function(basin, save_loc = "directory") {

  if (save_loc == "directory") {

    # Get working directory
    wd = getwd()
    # If the directory doesn't exist, then create the remarkdown_files folder
    if (!dir.exists(paste0(wd, "/rmarkdown_files"))) {
      print(paste0('Creating a new folder at: ', wd, "/rmarkdown_files", " where RMarkdown files will be saved"))
      dir.create('rmarkdown_files')
    }

    save_loc_f = paste0(wd, "/rmarkdown_files/")
  } else {
    save_loc_f = save_loc
  }

  rmarkdown::render(paste0("inst/droughtstats_prov_template.Rmd"),
                    params = list(region = basin),
                    output_file = paste0(save_loc_f, gsub(" ", "", basin)  ,  ".html"))

}
