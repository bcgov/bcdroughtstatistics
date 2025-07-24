
# Install from github instead of from .tar file
# remotes::install_github("bcgov/bcdroughtstatistics", force = TRUE)


# Path where tidyhydat downloads HYDAT by default
hydat_path <- tidyhydat::hy_default_db()

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


# library(bcdroughtstatistics)
#
# basins <- c("Cariboo Natural Resource Region",
#             "Kootenay-Boundary Natural Resource Region",
#             "Northeast Natural Resource Region",
#             "Omineca Natural Resource Region",
#             "Skeena Natural Resource Region",
#             "South Coast Natural Resource Region",
#             "Thompson-Okanagan Natural Resource Region",
#             "West Coast Natural Resource Region")

# Create output folder
# save_location <- normalizePath("output/", mustWork = FALSE)
# dir.create(save_location, recursive = TRUE, showWarnings = TRUE)
# save_location <- paste0(save_location,"\\")
# save_location <- gsub("\\\\", "/", save_location)

# save_location <- file.path(normalizePath("output", mustWork = FALSE), "")
# dir.create(save_location, recursive = TRUE, showWarnings = TRUE)

# save_location <- normalizePath("output", mustWork = FALSE)
# dir.create(save_location, recursive = TRUE, showWarnings = TRUE)
# print(save_location)

save_location <- tempfile("bcdrought_", tmpdir = tempdir())
dir.create(save_location)

# # save files using render_function
# # tryCatch({
# render_function_wc("West Coast Natural Resource Region", save_loc = paste0(save_location, "/"))
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[2], save_loc = save_location) #"Kootenay-Boundary Natural Resource Region"
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[3], save_loc = save_location) #"Northeast Natural Resource Region"
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[4], save_loc = save_location) #"Omineca Natural Resource Region"
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_to("Thompson-Okanagan Natural Resource Region", save_loc = save_location)
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[5], save_loc = save_location) # "Skeena Natural Resource Region"
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[1], save_loc = save_location) #"Cariboo Natural Resource Region"
# # }, error = function(e) {
# # })
# # tryCatch({
# bcdroughtstatistics::render_function_bc(basins[6], save_loc = save_location) #"South Coast Natural Resource Region"
# # }, error = function(e) {
# # })
