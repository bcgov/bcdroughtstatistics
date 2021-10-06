
#' @description Function for scraping drought polygons and levels from BC Drought Portal
#' @keywords internal
#' @export
#' @examples
#' @importFrom esri2sf esri2sf
#' @return Returns the polygons and drought levels from the current BC Drought Portal
#' scrape_drought_map()
scrape_drought_map <- function() {
  url <- "https://services6.arcgis.com/ubm4tcTYICKBpist/ArcGIS/rest/services/British_Columbia_Drought_Levels_View/FeatureServer/1"
  drought <- esri2sf::esri2sf(url, where = "DroughtLevel >= 0", outFields = c("DroughtLevel"), geomType = "esriGeometryPolygon") %>%
    dplyr::rename(geometry = "geoms") %>%
    as("Spatial") %>%
    sp::spTransform(sp::CRS("+proj=longlat +datum=WGS84")) %>%
    sp::spTransform(sp::CRS("+init=epsg:4326"))

  # -------------------------------
  # GET CENTROID OF DROUGHT BASIN POLYGONS
  # -------------------------------

  st_drought <- st_as_sf(drought, 4326) %>%
    dplyr::mutate(
      CENTROID = purrr::map(geometry, sf::st_centroid),
      COORDS = purrr::map(CENTROID, sf::st_coordinates),
      COORDS_X = purrr::map_dbl(COORDS, 1),
      COORDS_Y = purrr::map_dbl(COORDS, 2)
    )

  for (i in 1:dim(st_drought)[1]) {
    st_drought$label_m[i] <- paste0("Basin", i + 1)
  }

  st_drought <- st_drought %>%
    dplyr::mutate(BasinName = ifelse(label_m == "Basin10", "Fort Nelson",
      ifelse(label_m == "Basin11", "Northwest",
        ifelse(label_m == "Basin7", "Stikine",
          ifelse(label_m == "Basin5", "Finlay",
            ifelse(label_m == "Basin8", "North Peace",
              ifelse(label_m == "Basin12", "East Peace",
                ifelse(label_m == "Basin29", "Skeena Nass",
                  ifelse(label_m == "Basin28", "Haida Gwaii",
                    ifelse(label_m == "Basin2", "Bulkley-Lakes",
                      ifelse(label_m == "Basin6", "Upper Fraser West",
                        ifelse(label_m == "Basin3", "Parsnip",
                          ifelse(label_m == "Basin9", "South Peace",
                            ifelse(label_m == "Basin4", "Upper Fraser East",
                              ifelse(label_m == "Basin24", "Central Coast",
                                ifelse(label_m == "Basin26", "Middle Fraser",
                                  ifelse(label_m == "Basin27", "North Thompson",
                                    ifelse(label_m == "Basin25", "Upper Columbia",
                                      ifelse(label_m == "Basin17", "South Coast",
                                        ifelse(label_m == "Basin18", "Lower Fraser",
                                          ifelse(label_m == "Basin30", "Nicola",
                                            ifelse(label_m == "Basin33", "Coldwater",
                                              ifelse(label_m == "Basin13", "Skagit",
                                                ifelse(label_m == "Basin20", "Similkameen",
                                                  ifelse(label_m == "Basin21", "Okanagan",
                                                    ifelse(label_m == "Basin32", "Salmon",
                                                      ifelse(label_m == "Basin31", "South Thompson",
                                                        ifelse(label_m == "Basin19", "Kettle",
                                                          ifelse(label_m == "Basin16", "West Kootenay",
                                                            ifelse(label_m == "Basin14", "East Kootenay",
                                                              ifelse(label_m == "Basin22", "East Vancouver Island",
                                                                ifelse(label_m == "Basin23", "West Vancouver Island",
                                                                  ifelse(label_m == "Basin15", "Lower Columbia",
                                                                    "MISSING***"
                                                                  )
                                                                )
                                                              )
                                                            )
                                                          )
                                                        )
                                                      )
                                                    )
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    ))
}
