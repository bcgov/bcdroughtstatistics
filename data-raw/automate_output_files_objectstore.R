# Copyright 2025 Province of British Columbia
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

## Options and settings
Sys.setenv(TZ = "America/Vancouver")


## Packages
pkgs <- c(
  'pak',
  'aws.s3'
)

#Queries and installs missing packages
# options(timeout = 1200)
new.packages <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, lib = Sys.getenv("R_LIBS_USER"))


## bcdroughtstatistics package
pak::pak("bcgov/bcdroughtstatistics", lib = Sys.getenv("R_LIBS_USER"))


## Install HYDAT, if necessary

hydat_path <- tidyhydat::hy_default_db()# Path where tidyhydat downloads HYDAT by default

# Check if file exists
if (!file.exists(hydat_path)) {
  message("HYDAT not found. Downloading...")
  tidyhydat::download_hydat(ask = FALSE)
} else {
  # Optional: check if the file is older than 3 months
  age_days <- as.numeric(Sys.Date() - as.Date(file.info(hydat_path)$mtime))
  if (age_days > 30) {
    message("HYDAT is older than 3 months. Re-downloading...")
    tidyhydat::download_hydat(ask = FALSE)
  } else {
    message("HYDAT is up-to-date.")
  }
}


library(bcdroughtstatistics)

basins <- c("Cariboo Natural Resource Region",
            "Kootenay-Boundary Natural Resource Region",
            "Northeast Natural Resource Region",
            "Omineca Natural Resource Region",
            "Skeena Natural Resource Region",
            "South Coast Natural Resource Region",
            "Thompson-Okanagan Natural Resource Region",
            "West Coast Natural Resource Region")

# Create output folder
save_location <- tempfile("bcdrought_", tmpdir = tempdir())
dir.create(save_location)
save_location_r <- paste0(save_location, "/")

# # save files using render_function
# message("West Coast Natural Resource Region")
# # tryCatch({
# render_function_wc("West Coast Natural Resource Region", save_loc = save_location_r)
# # }, error = function(e) {
# # })
# message("Kootenay-Boundary Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[2], save_loc = save_location_r) #"Kootenay-Boundary Natural Resource Region"
# # }, error = function(e) {
# # })
# message("Northeast Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[3], save_loc = save_location_r) #"Northeast Natural Resource Region"
# # }, error = function(e) {
# # })
# message("Omineca Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[4], save_loc = save_location_r) #"Omineca Natural Resource Region"
# # }, error = function(e) {
# # })
# message("Thompson-Okanagan Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_to("Thompson-Okanagan Natural Resource Region", save_loc = save_location_r)
# # }, error = function(e) {
# # })
# message("Skeena Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[5], save_loc = save_location_r) # "Skeena Natural Resource Region"
# # }, error = function(e) {
# # })
# message("Cariboo Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[1], save_loc = save_location_r) #"Cariboo Natural Resource Region"
# # }, error = function(e) {
# # })
# message("South Coast Natural Resource Region")
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[6], save_loc = save_location_r) #"South Coast Natural Resource Region"
# # }, error = function(e) {
# # })


## Put html files to objectstore
library(aws.s3)

# Set your bucket and directory
bucket_name <- "rfc-conditions/drought_reports"
region <- ""

# Authenticate (these are read from env vars set in GitHub Actions)
Sys.setenv("AWS_ACCESS_KEY_ID" = Sys.getenv("AWS_ACCESS_KEY_ID"))
Sys.setenv("AWS_SECRET_ACCESS_KEY" = Sys.getenv("AWS_SECRET_ACCESS_KEY"))

# Upload all HTML files in the directory
files <- list.files(save_location, full.names = TRUE, pattern = "\\.html$")
for (file in files) {
  object_name <- basename(file)
  put_object(file = file,
             object = object_name,
             region = region,
             bucket = bucket_name,
             acl = "public-read")
}

