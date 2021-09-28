# Script for automating the creation of drought updates for all regions
rm(list=ls())
library(bcsnowstats)

basins <- c("Cariboo Natural Resource Region",
            "Kootenay-Boundary Natural Resource Region",
            "Northeast Natural Resource Region",
            "Omineca Natural Resource Region",
            "Skeena Natural Resource Region",
            "South Coast Natural Resource Region",
            "Thompson-Okanagan Natural Resource Region",
            "West Coast Natural Resource Region")

q_drive <- "Q:/Real-time_Data/Drought_regional_statistics/"

# save files using render_function
bcdroughtstatistics::render_function_wc(basins[8], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[1], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[2], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[3], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[4], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[5], save_loc = q_drive)
bcdroughtstatistics::render_function_bc(basins[6], save_loc = q_drive)
bcdroughtstatistics::render_function_to("Thompson-Okanagan Natural Resource Region", save_loc = q_drive)


