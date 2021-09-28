#' @description Function for downloading the correct BC government logo for superimposing on the snow basin index map
#' @keywords internal
#' @export
#' @examples
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
