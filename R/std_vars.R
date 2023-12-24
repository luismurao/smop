#' std_vars: Standardize predictors
#' @description Standardizes predictors by converting them into z-scores.
#' @param pred An object of class SpatRaster or matrix or data.frame
#' @param as_matrix Logical. If TRUE a matrix will be returned
#' @return A matrix or SpatRaster of standarized predictors
#' @details
#' if as_matrix is FALSE and  pred is a SpatRaster, the function would return
#' an SpatRaster object.
#'
#' @import Rcpp
#' @useDynLib smop
#' @export
#' @examples
#' pred_path <- system.file("extdata/G_layers", package = "smop") |>
#'                          list.files(full.names=TRUE)
#' pred <- terra::rast(pred_path)
#' std_bios <- smop::std_vars(pred,as_matrix=FALSE)
#' terra::plot(std_bios)


std_vars <- function(pred,as_matrix=TRUE){
  if(methods::is(pred,"SpatRaster")){
    m1 <- pred[]
  }
  if(is.data.frame(pred)){
    m1 <- as.matrix(pred)
  }
  if(!is.matrix(pred)){
    m1 <- as.matrix(pred)
  } else{
    m1 <- pred
  }
  medias_m1 <- colMeans(m1,na.rm = TRUE)
  stds_m1 <- sapply(1:ncol(m1), function(x) stats::sd(m1[,x],na.rm = TRUE))
  medias_mat <- matrix(rep(medias_m1, each=nrow(m1)),ncol = ncol(m1))
  stds_m1_mat <-  matrix(rep(stds_m1,each=nrow(m1)),ncol = ncol(m1))
  std_vars <- (m1 - medias_mat)/stds_m1_mat
  if(methods::is(pred,"SpatRaster") && !as_matrix){
   std_vars <- seq_len(terra::nlyr(pred)) |> purrr::map(function(x){
     p1 <- pred[[x]]
     p1[] <- std_vars[,x]
     return(p1)
   },.progress = TRUE)
   std_vars <- terra::rast(std_vars)
  }
  return(std_vars)
}
