# Script for automating the creation of drought updates for all regions
rm(list=ls())

library(bcdroughtstatistics)
library(pacman)

Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/Pandoc")
p_load(knitr, rmarkdown, sessioninfo)

basins <- c("Cariboo Natural Resource Region",
            "Kootenay-Boundary Natural Resource Region",
            "Northeast Natural Resource Region",
            "Omineca Natural Resource Region",
            "Skeena Natural Resource Region",
            "South Coast Natural Resource Region",
            "Thompson-Okanagan Natural Resource Region",
            "West Coast Natural Resource Region")

# BELOW IS FOR SERVER
save_loc <- "\\\\question.bcgov\\envwwwt\\rfc/Real-time_Data/Drought_regional_statistics/"
R_drive <- "\\\\answer.bcgov\\envwww\\rfc/Real-time_Data/Drought_regional_statistics/"


render_function <- function(basin){

  rmarkdown::render(paste0("regional_streamflow_html.Rmd"),
                    params = list(region = basin),
                    output_file = paste0(save_loc, gsub(" ", "", basin)  ,  ".html"))

  # Save a copy for this date
  file.copy(paste0(save_loc, gsub(" ", "", basin)  ,  ".html"),
            paste0(save_loc, gsub(" ", "", basin)  ,"_", Sys.Date(),  ".html"),
            overwrite = TRUE)

  # Copy a file to R drive
  file.copy(paste0(save_loc, gsub(" ", "", basin)  ,  ".html"),
            paste0(R_drive, gsub(" ", "", basin)  , ".html"),
            overwrite = TRUE)

}

render_function_TO <- function(basin){

  # rmarkdown::render(paste0("E:/Shared/Real-time_Data/Drought_regional_statistics/bcdroughtstatistics/inst/regional_streamflow_html.Rmd"),
  rmarkdown::render(paste0(system.file("TO_droughtstats_html.Rmd", package = "bcdroughtstatistics")),
                    params = list(region = basin),
                    output_file = paste0(save_loc, gsub(" ", "", basin)  ,  ".html"))

  # Save a copy for this date
  #file.copy(paste0(save_loc, gsub(" ", "", basin)  ,  ".html"),
  #          paste0(save_loc, gsub(" ", "", basin)  ,"_", Sys.Date(),  ".html"),
  #          overwrite = TRUE)

  # Copy a file to R drive
  #file.copy(paste0(save_loc, gsub(" ", "", basin)  ,  ".html"),
  #          paste0(R_drive, gsub(" ", "", basin)  , ".html"),
  #          overwrite = TRUE)

}

render_function(basin = basins[8])

render_function(basin = basins[1])
render_function(basin = basins[2])
render_function(basin = basins[3])
render_function(basin = basins[4])
render_function(basin = basins[5])
render_function(basin = basins[6])
render_function(basin = basins[7]) # issue

