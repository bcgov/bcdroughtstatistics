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



library(shiny)


shinyApp(
  ui = fluidPage(
    titlePanel("BC Drought Statistics"),
    selectInput("Region", "Choose Region to Retrieve Drought Statistics Table:", choices = c("Cariboo Natural Resource Region"="Cariboo Natural Resource Region",
                                                        "Kootenay-Boundary Natural Resource Region"="Kootenay-Boundary Natural Resource Region",
                                                        "Northeast Natural Resource Region" = "Northeast Natural Resource Region",
                                                        "Omineca Natural Resource Region" = "Omineca Natural Resource Region",
                                                        "Skeena Natural Resource Region" = "Skeena Natural Resource Region",
                                                        "South Coast Natural Resource Region" = "South Coast Natural Resource Region",
                                                        "Thompson-Okanagan Natural Resource Region" = "Thompson-Okanagan Natural Resource Region",
                                                        "West Coast Natural Resource Region" = "West Coast Natural Resource Region")),
    downloadButton('report', "Generate report")
  ),
  server = function(input, output) {
    output$report <- downloadHandler(
      # For PDF output, change this to "report.pdf"
      filename = paste0(Sys.Date(),"_droughtstatsreport.html"),
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        tempReport <- file.path(tempdir(), "regional_streamflow_html.Rmd")
        file.copy("regional_streamflow_html.Rmd", tempReport, overwrite = TRUE)

        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(input = tempReport,
                          output_file = file,
                          params = list(region = isolate(input$Region)),
                          envir = new.env(parent = globalenv())
        )
      }
    )
  }
)
