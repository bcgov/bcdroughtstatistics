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

#' Download BC Government Logo
#' @description Function for downloading the correct BC government logo for superimposing on the snow basin index map
#' @keywords internal
#' @export
#' @examples \dontrun{}
#' download_bc_logo()
download_bc_logo <- function() {
  file_loc <- file.path("data/BCID_V_rgb_pos.png")

  if (file.exists(file_loc)) {
    return(message(paste0("File already exists at ", file_loc)))
  }

  ## temp file to download
  tmp <- tempfile("logo_")

  res <- httr::GET(
    "http://www.corporate.gov.bc.ca/print-ads/Govt_of_BC_Logos/Resources/2018_BCID_Files.zip",
    httr::write_disk(tmp)
  )

  on.exit(file.remove(tmp))

  httr::stop_for_status(res)

  if (file.exists(tmp)) message("Extracting logo")

  utils::unzip(tmp,
    files = file.path("2018_BCID_Files/_Vertical/Positive/RGB/BCID_V_rgb_pos.png"),
    exdir = "data", overwrite = TRUE, junkpaths = TRUE
  )



  if (file.exists(file_loc)) message(paste0("File is located at ", file_loc))

  invisible(TRUE)
}
