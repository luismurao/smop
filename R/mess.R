#' mess: Multivariate Environmental Similarity Surface (MESS)
#'
#' @description mess calculates multivariate environmental similarity surfaces
#' as described by Elith et al., (2010) and optimized from the
#' mess function of the dismo-package.
#' @param M_calibra A SpatRaster or a Matrix of variables representing the
#' calibration area (M area in ENM context). If M_stack is matrix it should
#' contain the values of environmental variables as get it from
#' \code{\link[terra]{values}} function.
#' @param G_transfer A SpatRaster or a Matrix of variables representing areas
#' or scenarios to which models will be transferred. If G_stack is matrix it
#'  should contain the values of environmental variables as get it from
#'  \code{\link[terra]{values}} function.
#' @references Elith J., M. Kearney M., and S. Phillips, 2010. The art of
#'  modelling range-shifting species. Methods in Ecology and
#'  Evolution 1:330-342.
#' @return A SpatRaster or a matrix with MESS values
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
#' messVals <- smop::mess(M_calibra = m_calibra,
#'                        G_transfer = g_transfer)
#' terra::plot(messVals)
mess <- function(M_calibra, G_transfer){

  if(methods::is(M_calibra,"matrix"))
    mMat <- M_calibra
  if(methods::is(M_calibra,"SpatRaster"))
    mMat <- terra::values(M_calibra)
  if(methods::is(G_transfer, "SpatRaster")){
    gMat <- terra::values(G_transfer)
    mess_res <- G_transfer[[1]]
    gMat <- stats::na.omit(gMat)
    g_naIDs <- attr(gMat,"na.action")
  }

  mMat <- stats::na.omit(mMat)
  mMat_sorted <- apply(mMat,2,sort,decreasing=F)

  if(ncol(gMat) == ncol(mMat)){

    c1 <- seq_len(ncol(mMat)) |>
      purrr::map(~.dismo_mess2(gVar =gMat[,.x],
                               mVar = mMat_sorted[,.x] ))
    min_1 <- do.call(base::pmin, c1 )
    mess_vals <- rep(NA,terra::ncell(mess_res))
    if(length(g_naIDs) > 0L) {
      mess_vals[-g_naIDs] <- min_1
    } else{
      mess_vals <- min_1
    }
    mess_res[] <- mess_vals
    names(mess_res) <- "MESS"
    return(mess_res)
  }
  stop("M_calibra and G_transfer must have the same number of variables")
}

.dismo_mess2 <- function(gVar,mVar){
  nrowsM <-  length(mVar)
  comp_list <- list(gVar,mVar)
  intI <- do.call(base::findInterval, comp_list)
  f<-100*intI/nrowsM
  maxv <- max(comp_list[[2]])
  minv <- min(comp_list[[2]])
  #opt1 <- 100*(comp_list[[1]]-minv)/(maxv-minv)
  #opt2 <- 2*f
  #opt3 <- 2 * (100-f)
  #opt4 <- 100*(maxv-comp_list[[1]])/(maxv-minv)
  simi <- ifelse(f==0, 100*(comp_list[[1]]-minv)/(maxv-minv),
                 ifelse(f<=50, 2*f,
                        ifelse(f<100, 2 * (100-f),
                               100*(maxv-comp_list[[1]])/(maxv-minv))))
  return(simi)
}
