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

#' Scrape drought map for drought levels and polygons
#' @description Function for scraping drought polygons and levels from BC Drought Portal
#' @keywords internal
#' @export
#' @examples \dontrun{}
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

  st_drought <- sf::st_as_sf(drought, 4326) %>%
    dplyr::mutate(
      CENTROID = purrr::map(geometry, sf::st_centroid),
      COORDS = purrr::map(CENTROID, sf::st_coordinates),
      COORDS_X = purrr::map_dbl(COORDS, 1),
      COORDS_Y = purrr::map_dbl(COORDS, 2)
    )

  for (i in 1:dim(st_drought)[1]) {
    st_drought$label_m[i] <- paste0("Basin", i + 1)
  }

  leaflet(width = "100%") %>%
    addProviderTiles("Esri.WorldTopoMap") %>%
    fitBounds(48, 50, -139, -120) %>%
    setView( lng = -126, lat = 54.2, zoom = 5 ) %>%
    addPolygons(data = st_drought,
                #group = "BC Provincial Drought Polygons",
                #weight = 3,
                #color = '#2900b6',
                #fillColor = '#white', fillOpacity = 0, # completely opaque BC Provincial Drought Polygons for now
                #highlightOptions = highlightOptions(color = '#00cccc', weight = 3,
                #bringToFront = FALSE),
                label = ~st_drought$label_m)

  st_drought <- st_drought %>%
    dplyr::mutate(BasinName = ifelse(label_m == "Basin10", "Fort Nelson",
      ifelse(label_m == "Basin11", "Northwest",
        ifelse(label_m == "Basin7", "Stikine",
          ifelse(label_m == "Basin5", "Finlay",
            ifelse(label_m == "Basin8", "North Peace",
              ifelse(label_m == "Basin12", "East Peace",
                ifelse(label_m == "Basin24", "Skeena Nass",
                  ifelse(label_m == "Basin23", "Haida Gwaii",
                    ifelse(label_m == "Basin2", "Bulkley-Lakes",
                      ifelse(label_m == "Basin6", "Upper Fraser West",
                        ifelse(label_m == "Basin3", "Parsnip",
                          ifelse(label_m == "Basin9", "South Peace",
                            ifelse(label_m == "Basin4", "Upper Fraser East",
                              ifelse(label_m == "Basin20", "Central Coast",
                                ifelse(label_m == "Basin30", "Middle Fraser",
                                  ifelse(label_m == "Basin22", "North Thompson",
                                    ifelse(label_m == "Basin21", "Upper Columbia",
                                     ifelse(label_m == "Basin14", "Lower Columbia",
                                      ifelse(label_m == "Basin33", "Central Pacific Range Basin",
                                        ifelse(label_m == "Basin32", "Eastern Pacific Range Basin",
                                          ifelse(label_m == "Basin31", "Sunshine Coast Basin",
                                        ifelse(label_m == "Basin34", "Lower Mainland Basin",
                                      ifelse(label_m == "Basin17", "Similkameen",
                                     ifelse(label_m == "Basin28", "Coldwater",
                                    ifelse(label_m == "Basin25", "Nicola",
                                 ifelse(label_m == "Basin18", "Okanagan",
                                ifelse(label_m == "Basin27", "Salmon",
                               ifelse(label_m == "Basin26", "South Thompson",
                              ifelse(label_m == "Basin35", "Lower Thompson",
                          ifelse(label_m == "Basin16", "Kettle",
                                                          ifelse(label_m == "Basin15", "West Kootenay",
                                                            ifelse(label_m == "Basin13", "East Kootenay",
                                                              ifelse(label_m == "Basin29", "East Vancouver Island",
                                                                ifelse(label_m == "Basin19", "West Vancouver Island",
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
      )))))
}
