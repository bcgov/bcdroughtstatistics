
#
# This work is licensed under the Creative Commons Attribution 4.0 International License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/.

#' Function to get a new token if process takes too long (for tidyhydat.ws())
#' @description Function to get a new token if process takes too long (for tidyhydat.ws())
#' @keywords get new token
#' @export
#' @examples \dontrun{}

start.time <- Sys.time()

end.time <- Sys.time()
time.taken <- as.numeric(end.time) - as.numeric(start.time)

if(time.taken>=8*60){
  ## Get token again
  token_out <- token_ws()
  start.time <- Sys.time() #Reset the beginning of the time
}


