#' mop_distance: Estimate mop distance between two matrices
#' @description mop_distances calculates the Euclidean distance
#' between two matrices.
#' @param M A numeric matrix of dimension n x m
#' @param G A numeric matrix of dimension n x m
#' @return A numeric value that represents the Euclidean distance between the
#' two matrices
#' @import Rcpp
#' @useDynLib smop
#' @export
#' @examples
#'
#' set.seed(111)
#' n=1000
#' M <- matrix(rnorm(4*n), 2*n, 2)
#' G <- matrix(rnorm(4*n), 2*n, 2)
#' mdist <- smop::mop_distance(M,G)

mop_distance <- function(M,G){
  distm <- calcDistance(M,G)
  return(distm)
}
