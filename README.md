<!-- Add a project state badge
See https://github.com/BCDevExchange/Our-Project-Docs/blob/master/discussion/projectstates.md
If you have bcgovr installed and you use RStudio, click the 'Insert BCDevex Badge' Addin. -->

[![img](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

# bcdroughtstatistics

The primary output of this package are RMarkdown products that create
tables and maps of drought relevant statistics for the province of
British Columbia. These RMarkdown drought statistics packages are
aligned by natural resource region, and have been developed with the
input from staff from these regions who are tasked with managing and
monitoring the progression of drought. Drought statistics are compiled
to demonstrate the severity of hydrologic drought within a particular
natural resource management region. Also included is a ‘Low Flow
Advisory’ RMarkdown product that shows which streams across the entire
province are low, and thus experiencing moderate to severe hydrologic
drought impacts.

### Features

This package features three functions that render three variations on
the drought statistics product. Two of the functions return drought
statistics products tailored for specific regions within British
Columbia; the third function returns the Low Flow Advisory product.

### Installation

You can install bcdroughtstatistics() from this Github repository using
the remotes package though install.packages(“remotes”).

``` r
remotes::install_github("bcgov/bcdroughtstatistics")
#> Downloading GitHub repo bcgov/bcdroughtstatistics@HEAD
#> Skipping 1 packages not available: tidyhydat.ws
#>          checking for file 'C:\Users\AJOLLYMO\AppData\Local\Temp\RtmpcxJGME\remotes1c05f747731\bcgov-bcdroughtstatistics-461ef4a/DESCRIPTION' ...     checking for file 'C:\Users\AJOLLYMO\AppData\Local\Temp\RtmpcxJGME\remotes1c05f747731\bcgov-bcdroughtstatistics-461ef4a/DESCRIPTION' ...   v  checking for file 'C:\Users\AJOLLYMO\AppData\Local\Temp\RtmpcxJGME\remotes1c05f747731\bcgov-bcdroughtstatistics-461ef4a/DESCRIPTION' (487ms)
#>       -  preparing 'bcdroughtstatistics': (1.9s)
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   v  checking DESCRIPTION meta-information
#>       -  checking for LF line-endings in source and make files and shell scripts
#>       -  checking for empty or unneeded directories
#>      Omitted 'LazyData' from DESCRIPTION
#>       -  building 'bcdroughtstatistics_0.0.0.9000.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/AJOLLYMO/R/win-library/4.1'
#> (as 'lib' is unspecified)
library(bcdroughtstatistics)
```

### Usage

#### Example

An html version of the drought statistics package can be generated for a
specific natural resource management region in BC

``` r
library(bcdroughtstatistics)

# All of the NRM regions in BC
basins <- c("Cariboo Natural Resource Region",
            "Kootenay-Boundary Natural Resource Region",
            "Northeast Natural Resource Region",
            "Omineca Natural Resource Region",
            "Skeena Natural Resource Region",
            "South Coast Natural Resource Region",
            "Thompson-Okanagan Natural Resource Region",
            "West Coast Natural Resource Region")

## Get the Drought Statistics page for the West Coast without saving

drought_stats_wc(basin = "West Coast Natural Resource Region", save = FALSE)
#> 
#> 
#> processing file: regional_streamflow_html.Rmd
#>   |                                                                              |                                                                      |   0%  |                                                                              |...                                                                   |   4%
#>    inline R code fragments
#> 
#>   |                                                                              |......                                                                |   8%
#> label: packages (with options) 
#> List of 1
#>  $ include: logi FALSE
#> 
#>   |                                                                              |........                                                              |  12%
#>   ordinary text without R code
#> 
#>   |                                                                              |...........                                                           |  16%
#> label: setup (with options) 
#> List of 1
#>  $ include: logi FALSE
#> 
#>   |                                                                              |..............                                                        |  20%
#>   ordinary text without R code
#> 
#>   |                                                                              |.................                                                     |  24%
#> label: load (with options) 
#> List of 1
#>  $ include: logi FALSE
#> 
#>   |                                                                              |....................                                                  |  28%
#>   ordinary text without R code
#> 
#>   |                                                                              |......................                                                |  32%
#> label: clean (with options) 
#> List of 3
#>  $ message : logi FALSE
#>  $ warnings: logi FALSE
#>  $ include : logi FALSE
#> Layer Type: Feature Layer
#> Geometry Type: esriGeometryPolygon
#> Service Coordinate Reference System: 3857
#> Output Coordinate Reference System: 4326
#> nr_regions was updated on 2021-04-13
#> Warning: attribute variables are assumed to be spatially constant throughout all
#> geometries

#> Warning: attribute variables are assumed to be spatially constant throughout all
#> geometries
#> watercourses_5M was updated on NULL
#> Warning: attribute variables are assumed to be spatially constant throughout all
#> geometries

#> Warning: attribute variables are assumed to be spatially constant throughout all
#> geometries
#>   |                                                                              |.........................                                             |  36%
#>   ordinary text without R code
#> 
#>   |                                                                              |............................                                          |  40%
#> label: analysisinstant
#> Adding missing grouping variables: `STATION_NUMBER`
#> Joining, by = "STATION_NUMBER"
#> Adding missing grouping variables: `STATION_NUMBER`
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = c("STATION_NAME", "STATION_NUMBER")
#> This token will expire at 15:14:03
#> The following station(s) were not retrieved: 08HBX87
#> Check station number for typos or if it is a valid station in the network
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = c("STATION_NAME", "STATION_NUMBER")
#> Joining, by = "STATION_NUMBER"
#> Joining, by = "STATION_NUMBER"
#> Joining, by = c("STATION_NUMBER", "Q_7day", "Date")
#> Joining, by = c("STATION_NAME", "STATION_NUMBER")
#> Joining, by = c("STATION_NAME", "STATION_NUMBER", "Instant Q", "LATITUDE", "LONGITUDE", "Q_24hours", "%tile-last24", "pct_bin_24hours", "%tile-7day_mean", "pct_bin_7day", "Q_7day", "Record Length", "regulation", "mean_Q7_forthisdate", "median_Q7_forthisdate", "Per_Q7_median", "Per_Q7_mean", "basin_area", "maxtemp7daymean", "maxtemp24hours", "mintemp24hours", "meantemp24hours", "Was the site warmer than 23degC in the last 7 days?", "Dates_above23threshold", "Was the site warmer than 20degC in the last 7 days?", "Dates_above20threshold", "Date", "Q7_value", "Q7_prctile", "min_Q7", "MAD (m^3/s)", "MeanDailyQ", "% MAD", "% MAD_Q_24hours", "MAD_bin", "MAD_bin_q24")
#>   |                                                                              |...............................                                       |  44%
#>    inline R code fragments
#> 
#>   |                                                                              |..................................                                    |  48%
#> label: output (with options) 
#> List of 3
#>  $ fig.height: num 5.8
#>  $ fig.width : num 6.4
#>  $ fig.align : chr "center"
#> 
#>   |                                                                              |....................................                                  |  52%
#>    inline R code fragments
#> 
#>   |                                                                              |.......................................                               |  56%
#> label: belownormal
#>   |                                                                              |..........................................                            |  60%
#>    inline R code fragments
#> 
#>   |                                                                              |.............................................                         |  64%
#> label: MADmap (with options) 
#> List of 3
#>  $ fig.height: num 5.8
#>  $ fig.width : num 6.4
#>  $ fig.align : chr "center"
#> 
#>   |                                                                              |................................................                      |  68%
#>    inline R code fragments
#> 
#>   |                                                                              |..................................................                    |  72%
#> label: madtable
#>   |                                                                              |.....................................................                 |  76%
#>    inline R code fragments
#> 
#>   |                                                                              |........................................................              |  80%
#> label: watertempmaps
#>   |                                                                              |...........................................................           |  84%
#>    inline R code fragments
#> 
#>   |                                                                              |..............................................................        |  88%
#> label: watertemp
#>   |                                                                              |................................................................      |  92%
#>    inline R code fragments
#> 
#>   |                                                                              |...................................................................   |  96%
#> label: statstable
#>   |                                                                              |......................................................................| 100%
#>   ordinary text without R code
#> output file: regional_streamflow_html.knit.md
#> "C:/Program Files/RStudio/bin/pandoc/pandoc" +RTS -K512m -RTS regional_streamflow_html.knit.md --to html4 --from markdown+autolink_bare_uris+tex_math_single_backslash --output FALSEWestCoastNaturalResourceRegion.html --lua-filter "C:\Users\AJOLLYMO\R\win-library\4.1\rmarkdown\rmarkdown\lua\pagebreak.lua" --lua-filter "C:\Users\AJOLLYMO\R\win-library\4.1\rmarkdown\rmarkdown\lua\latex-div.lua" --self-contained --variable bs3=TRUE --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template "C:\Users\AJOLLYMO\R\win-library\4.1\rmarkdown\rmd\h\default.html" --no-highlight --variable highlightjs=1 --variable theme=bootstrap --include-in-header "C:\Users\AJOLLYMO\AppData\Local\Temp\RtmpcxJGME\rmarkdown-str1c04b4d32ed.html" --mathjax --variable "mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
#> 
#> Output created: FALSEWestCoastNaturalResourceRegion.html
```

### Project Status

In development.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/bcdroughtstatistics/issues/).

### How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

    Copyright 2021 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
