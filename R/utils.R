
#
# This work is licensed under the Creative Commons Attribution 4.0 International License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/.

start.time <- Sys.time()

end.time <- Sys.time()
time.taken <- as.numeric(end.time) - as.numeric(start.time)

if(time.taken>=8*60){
  ## Get token again
  token_out <- token_ws()
  start.time <- Sys.time() #Reset the beginning of the time
}


#data_dir <- function() {
#  # Use tools::R_user_dir on R >= 4.0, rappdirs otherwise.
#  R_user_dir <- getNamespace("tools")$R_user_dir
#  if (!is.null(R_user_dir)) {
#    getOption("bcdroughtstats.data_dir", default = R_user_dir("bcdroughtstatistics", "cache"))
#  } else {
#    getOption("bcmaps.data_dir", default = rappdirs::user_cache_dir("bcmaps"))
#  }
#}
