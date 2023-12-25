#' extrapolation_zones: A simple function to map extrapolation zones
#' @description Maps strict extrapolation zones
#' @param M_calibra An object of class SpatRaster or a matrix of predictors
#' for the calibration area
#' (M area in ENM context).
#' @param G_transfer An object of class SpatRaster or a matrix of predictors
#' for the transfer area
#' @param as_vec Logical. Whether return cell ids of extrapolating pixels or not
#' @return Returns a binary map showing strict extrapolation zones (ones). If
#' the parameter as_vec is TRUE, the function return pixel ids of strict
#' extrapolation.
#' @useDynLib smop
#' @export
#' @examples
#' # Predictors
#' m_path <- system.file("extdata/M_layers", package = "smop") |>
#'                        list.files(full.names=TRUE)
#' g_path <- system.file("extdata/G_layers", package = "smop") |>
#'                        list.files(full.names=TRUE)
#' M_calibra <- terra::rast(m_path)
#' G_transfer <- terra::rast(g_path)
#' \donttest{
#' # extr_zones <- smop::extrapolation_zones(M_calibra = M_calibra,
#' #                                         G_transfer = G_transfer,
#' #                                         as_vec =FALSE)
#' #
#' # terra::plot(extr_zones)
#' # extr_zones_ids <- smop::extrapolation_zones(M_calibra = M_calibra,
#' #                                             G_transfer = G_transfer,
#' #                                             as_vec =TRUE)
#' # head(extr_zones_ids)
#' }
extrapolation_zones <- function(M_calibra, G_transfer,as_vec =FALSE){
  if(methods::is(M_calibra,"SpatRaster")){
    m1 <- terra::values(M_calibra)
  }
  if(is.data.frame(M_calibra)){
    m1 <- as.matrix(M_calibra)
  }
  if(is.matrix(M_calibra)){
    m1 <- M_calibra
  }
  if(!is.matrix(m1)){
    stop("M1 should be of class SpatRaster or matrix or data.frame")
  }
  if(methods::is(G_transfer,"SpatRaster")){
    g1 <-  terra::values(G_transfer)
  }
  if(is.data.frame(G_transfer)){
    g1 <- as.matrix(G_transfer)
  }
  if(is.matrix(G_transfer)){
    g1 <- G_transfer
  }
  if(!is.matrix(g1)){
    stop("G1 should be of class SpatRaster or matrix or data.frame")
  }

  npreds <- ncol(m1)
  ids_extra <- seq_len(npreds) |> purrr::map(function(x){
    var_min <- min(m1[, x], na.rm = TRUE)
    var_max <- max(m1[, x], na.rm = TRUE)
    l1 <- which(g1[, x] < var_min | g1[, x] > var_max)
    return(l1)
  },.progress = TRUE)
  ids_extra <- unique(unlist(ids_extra))
  if(methods::is(G_transfer,"SpatRaster") && !as_vec){
    extrapo <- G_transfer[[1]]*0
    extrapo[ids_extra] <-  1
    names(extrapo) <- "extrapolation"
  } else{
    extrapo <- ids_extra
  }
  return(extrapo)

}
