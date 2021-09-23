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

The [BC River Forecast
Centre](https://www2.gov.bc.ca/gov/content/environment/air-land-water/water/drought-flooding-dikes-dams/river-forecast-centre)
uses bcdroughtstatistics() to produce drought statistics products for
all natural resource management regions on a daily basis during the
summer months; an example of the West Coast drought statistics format
can be found
[here](http://bcrfc.env.gov.bc.ca/Real-time_Data/Drought_regional_statistics/WestCoastNaturalResourceRegion.html).

Note that this package takes real-time streamflow and stream temperature
data from the Water Survey of Canada. Thus, users need to obtain a token
from the Water Survey of Canada that must be stored within a .REnviron
file separate from this package in order to access its full
functionality.

### Features

This package features three functions that render three variations on
the drought statistics product. Two of the functions return drought
statistics products tailored for specific regions within British
Columbia; the third function returns the Low Flow Advisory product.

### Installation

You can install bcdroughtstatistics() from this Github repository using
the remotes package.

    install.packages("remotes")

    remotes::install_github("bcgov/bcdroughtstatistics")
    library(bcdroughtstatistics)

### Usage

#### Example

An html version of the drought statistics package can be generated for a
specific natural resource management region in BC using either
render_function_wc() or render_function_to(). If you don’t specify where
to save the RMarkdown file, then the code will automatically create a
new folder in your working directory named “rmarkdown_files” into which
the html product will be saved.


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

    ## Get the Drought Statistics page for the West Coast, saving to current working directory

    render_function_wc(basin = "West Coast Natural Resource Region")

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
