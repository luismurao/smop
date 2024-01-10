#' Exdet univariate: NT1 metric, univariate extrapolation risk analysis for
#' model transfer
#'
#' @description exdet_univa calculates NT1 metric.
#' @param M_calibra A SpatRaster or a Matrix of variables representing the
#' calibration area (M area in ENM context). If M_calibra is matrix it should
#' contain the values of environmental variables as get it from
#' \code{\link[terra]{values}} function.
#' @param G_transfer A SpatRaster or a Matrix of variables representing areas
#' or scenarios to which models will be transferred. If G_transfer is matrix
#' it should contain the values of environmental variables as get it
#' from \code{\link[terra]{values}} function.
#' @param G_mold a Raster representing the extent of the projection area.
#' This is only necessary when G_stack is of class matrix; G_mold will we
#' use as a mold to save the NT1 values computed by exdet_univa function.
#' @details The exdet univariate (\code{\link[smop]{exdet_univar}})
#' and multivariate (\code{\link[smop]{exdet_multvar}}) is calculated
#' following: Mesgaran, M.B., Cousens, R.D. & Webber, B.L. (2014)
#' Here be dragons: a tool for quantifying novelty due to covariate
#' range and correlation change when projecting species distribution models.
#' Diversity & Distributions, 20: 1147–1159, DOI: 10.1111/ddi.12209.
#' @return NT1 metric (univariate extrapolation) as a SpatRaster object.
#' @export
#'
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
#' NT1 <- smop::exdet_univar(M_calibra = m_calibra,
#'                           G_transfer = g_transfer,G_mold=NULL)
#' terra::plot(NT1)
#'
exdet_univar <- function(M_calibra, G_transfer,G_mold=NULL) {

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

  max_min_mvector <- sapply(seq_len(ncol(g_Values)),
                            function(x) range(m_Values[,x],na.rm = T))
  min_mvector <- matrix(rep(max_min_mvector[1,],
                            each=nrow(g_Values)),
                        nrow =nrow(g_Values) )
  max_mvector <- matrix(rep(max_min_mvector[2,],
                            each=nrow(g_Values)),
                        nrow =nrow(g_Values) )
  gMin <- g_Values - min_mvector
  gMax <- max_mvector - g_Values
  max_min <-  max_mvector[1,] - min_mvector[1,]

  udij <- sapply(seq_len(ncol(gMin)), function(x) {
    comp_vec <- data.frame(gMin[,x],gMax[,x],0)
    min_1 <- do.call(base::pmin, comp_vec)
    return( min_1 /  max_min[x])
  })

  nt1 <- base::rowSums(udij,na.rm = F)
  extD[] <- nt1
  names(extD) <- "NT1"
  return(extD)
}
