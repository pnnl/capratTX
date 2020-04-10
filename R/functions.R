#' read_ERCOT_data
#' @details ...
#' @param res_filepath full path to reservoir data file for ERCOT
#' @importFrom readxl read_xlsx
#' @export
#'
read_ERCOT_data <- function(res_filepath) {

  # 1. Generator info
  read_xlsx(res_filepath, sheet = "Generator Info", skip = 1) ->
    generator_info

  # 2. Reservoirs info
  read_xlsx(res_filepath, sheet = "Reservoirs Info") ->
    reservoir_info

  # 3. Storage records
  read_xlsx(res_filepath, sheet = "Storage Levels") ->
    storage_levels

  # 4. Bathymetry
  read_xlsx(res_filepath, sheet = "Bathymetry") ->
    bathymetry

  return(
    list("generator_info" = generator_info,
         "reservoir_info" = reservoir_info,
         "storage_levels" = storage_levels,
         "bathymetry" = bathymetry)
  )

}


#' read_controlflows
#' @details ...
#' @param res_filepath full path to reservoir data file for ERCOT
#' @importFrom purrr map_dfr
#' @importFrom vroom vroom cols
#' @importFrom dplyr select one_of
#' @export
#'
read_controlflows <- function(reservoir){

  # replace space with _ for reservoir column names
  gsub(" ", "_", reservoir) -> reservoir_
  if(reservoir_ == "STP"){
    reservoir_ <- "South_Texas_Project_Reservoir"
  }

  vroom_silent(paste0(system.file("extdata/", package = "ECRAT"),
                      "/Control/", reservoir_, ".csv")) %>%
    select(-reservoir) -> controlflows

  return(controlflows)

}


#' read_gcm_flows
#' @details ...
#' @param reservoir ...
#' @param gcm gcm
#' @param period "baseline" or "future"
#' @importFrom purrr map_dfr
#' @importFrom vroom vroom cols
#' @importFrom dplyr select one_of
#' @export
#'
read_gcm_flows <- function(reservoir, gcm, period){

  list.files(
    paste0(system.file("extdata/", package = "ECRAT"), "/gcm"),
    full = T
  ) %>%
    .[grepl(gcm, .)] %>%
    .[grepl(period, .)] -> gcm_file_dir


  # replace space with _ for reservoir column names
  gsub(" ", "_", reservoir) -> reservoir_
  if(reservoir_ == "STP"){
    reservoir_ <- "South_Texas_Project_Reservoir"
  }

  vroom_silent(paste0(gcm_file_dir, "/", reservoir_, ".csv")) %>%
    select(date, flow) -> gcm_flows

  return(gcm_flows)

}



box_cox_transform <- function(x, lamda){
  ((1 + x) ^ lamda - 1) / lamda
}


vroom_silent <- function(x) vroom(x, col_types = cols())
