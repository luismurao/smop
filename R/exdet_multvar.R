#' Exdet multivariate: NT2 metric, multivariate extrapolation risk analysis for model transfer
#'
#' @description exdet_multvar calculates NT2 metric.
#' @param M_calibra A SpatRaster or a Matrix of variables representing the
#' calibration area (M area in ENM context). If M_stack is matrix it should
#' contain the values of environmental variables as get it from
#' \code{\link[terra]{values}} function.
#' @param G_transfer A SpatRaster or a Matrix of variables representing areas
#' or scenarios to which models will be transferred. If G_stack is matrix it
#' should contain the values of environmental variables as get it from
#'  \code{\link[terra]{values}} function.
#' @param G_mold A SpatRaster representing the extent of the projection area.
#' This is only necessary when G_stack is of class matrix; G_mold will
#' we use as a mold to save the NT1 values computed by exdet_univa function.
#' @return NT2 metric (multivariate extrapolation) as a SpatRaster object.
#' @details The exdet univariate (\code{\link[smop]{exdet_univar}}) and
#' multivariate (\code{\link[smop]{exdet_multvar}}) is calculated following:
#' Mesgaran, M.B., Cousens, R.D. & Webber, B.L. (2014) Here be dragons:
#'  a tool for quantifying novelty due to covariate range and correlation
#'  change when projecting species distribution models.
#'  Diversity & Distributions, 20: 1147–1159, DOI: 10.1111/ddi.12209.
#' @export
#' @examples
#' m_calibra <- terra::rast(list.files(system.file("extdata/M_layers",
#'                                     package = "smop"),
#'                                     pattern = ".tif$",
#'                                     full.names = TRUE))
#' g_transfer <- terra::rast(list.files(system.file("extdata/G_layers",
#'                                     package = "smop"),
#'                                     pattern = ".tif$",
#'                                     full.names = TRUE))
#'
#' \dontrun{
#' NT2 <- smop::exdet_multvar(M_calibra = m_calibra,
#'                            G_transfer = g_transfer)
#' terra::plot(NT2)
#' }

exdet_multvar <- function(M_calibra, G_transfer,G_mold=NULL) {

  if(methods::is(M_calibra, "matrix"))
    m_Values <- M_calibra
  if(methods::is(M_calibra, "SpatRaster"))
    m_Values <- terra::values(M_calibra)
  if(methods::is(G_transfer, "SpatRaster")){
    extD <- G_transfer[[1]]
    g_Values <- terra::values(G_transfer)
  }
  if(methods::is(G_transfer, "matrix") && methods::is(G_mold, "SpatRaster")){
    g_Values <- G_transfer
    extD <- G_mold
  }


  mu_m  <- base::colMeans(m_Values,na.rm = T)
  var_m<-  stats::var(m_Values,na.rm = T)
  maha_m <- stats::mahalanobis(x = m_Values,
                               center = mu_m,
                               cov = var_m,na.rm = T)
  maha_g <- stats::mahalanobis(x = g_Values,
                               center = mu_m,
                               cov = var_m,na.rm = T)
  maha_max <- max(maha_m,na.rm = T)
  NT2 <- maha_g / maha_max
  extD[] <- NT2
  names(extD) <- "NT2"
  return(extD)
}
