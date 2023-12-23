#' MOP: Extrapolation risk analysis for model transfer
#'
#' @description mop calculates a Mobility-Oriented Parity
#' @param M_calibra A SpatRaster of variables representing the calibration area
#' (M area in ENM context).
#' @param G_transfer A SpatRaster of variables representing areas or scenarios
#'  to which models will be transferred.
#' @param percent (numeric) percent of values sampled from the calibration
#' region to calculate the MOP.
#' @param normalized (logical) if TRUE mop output will be normalized to 1.
#' @param standardize_vars Logical. Standardize predictors see
#' @param comp_each (numeric) compute distance matrix for a each fixed number
#'  of rows (default = 100). This parameter is for paralleling the MOP
#' computations using the furrr package, see example 2.
#' @return A SpatRaster object of MOP distances.
#' @details
#' The MOP is calculated following Owens et al.
#' (2013; https://doi.org/10.1016/j.ecolmodel.2013.04.011).
#' This function is a modification of the MOP function in ntbox R package.
#'
#' @importFrom future plan
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
#' # Example 1 compute mop distance in serial
#' mop_test <- smop::mop(M_calibra = M_calibra, G_transfer =  G_transfer,
#'                       percent = 20,comp_each = NULL,
#'                       normalized = TRUE, standardize_vars=TRUE)
#' terra::plot(mop_test)
#' \donttest{
#' # Example 2: Run the mop function in parallel
#' future::plan("future::multisession",workers = 2)
#' mop_test_parallel <- smop::mop(M_calibra = M_calibra,
#'                                G_transfer =  G_transfer,
#'                                percent = 20,comp_each = 500,
#'                                normalized = TRUE, standardize_vars=TRUE)
#' future::plan("future::sequential")
#' terra::plot(mop_test_parallel)
#' }


mop <- function (M_calibra, G_transfer, percent = 10, comp_each = NULL,
                 normalized = TRUE, standardize_vars=TRUE){

  if(methods::is(M_calibra,"SpatRaster")){
    m1 <- terra::values(M_calibra)
  }
  if(is.data.frame(M_calibra)){
    m1 <- as.matrix(M_calibra)
  }
  if(!is.matrix(m1)){
    stop("M1 should be of class SpatRaster or matrix or data.frame")
  }
  if(methods::is(G_transfer,"SpatRaster")){
    g1 <- terra::values(G_transfer)
  }
  if(is.data.frame(G_transfer)){
    g1 <- as.matrix(G_transfer)
  }
  if(!is.matrix(g1)){
    stop("G1 should be of class SpatRaster or matrix or data.frame")
  }
  # Check extrapolation zones
  ids_extrapol <- smop::extrapolation_zones(M_calibra = m1,G_transfer = g1,
                                            as_vec = FALSE)
  # Discard extrapolation zones in mop computation
  if(length(ids_extrapol)> 0L){
    g1[ids_extrapol,] <- NA
  }
  if(standardize_vars){
    m1 <- smop::std_vars(pred = m1, as_matrix = TRUE)
    g1 <- smop::std_vars(pred = g1, as_matrix = TRUE)
  }
  m1 <- m1 |> stats::na.omit()
  g1 <- g1 |> stats::na.omit()
  ids_na <- stats::na.action(g1)
  if(is.numeric(comp_each)){
    n_parts <- ceiling(nrow(g1)/comp_each)
    partitions <- cut(seq_len(nrow(g1)),n_parts)
    g1L <- split(as.data.frame(g1),partitions)
  } else{
    g1L <- list(g1)
  }
  options(future.globals.maxSize = 388500 * 1024^2)
  rmop <- seq_along(g1L) |> furrr::future_map(function(x){
    g1_split <- as.matrix(g1L[[x]])
    r1 <- calcMOP(m1,g1_split,prob =percent/100)
    return(r1)
  },.progress = TRUE,
  .options = furrr::furrr_options(seed = NULL,globals = c("g1L","m1")))
  rmop <- unlist(rmop)
  if(normalized){
    m_min <- min(rmop,na.rm = TRUE)
    m_max <- max(rmop,na.rm = TRUE)
    rmop <- 1.0001- ((rmop - m_min) / (m_max - m_min))
  }
  rmopr <- rep(NA, terra::ncell(G_transfer[[1]]))
  rmopr[-ids_na] <- rmop
  if(length(ids_extrapol)> 0L){
    rmopr[ids_extrapol] <- 0
  }
  rmop <- G_transfer[[1]]
  rmop[] <- rmopr

  names(rmop) <- "MOP"
  return(rmop)

}

