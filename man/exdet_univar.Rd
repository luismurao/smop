% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exdet_univar.R
\name{exdet_univar}
\alias{exdet_univar}
\title{Exdet univariate: NT1 metric, univariate extrapolation risk analysis for
model transfer}
\usage{
exdet_univar(M_calibra, G_transfer, G_mold = NULL)
}
\arguments{
\item{M_calibra}{A SpatRaster or a Matrix of variables representing the
calibration area (M area in ENM context). If M_calibra is matrix it should
contain the values of environmental variables as get it from
\code{\link[terra]{values}} function.}

\item{G_transfer}{A SpatRaster or a Matrix of variables representing areas
or scenarios to which models will be transferred. If G_transfer is matrix
it should contain the values of environmental variables as get it
from \code{\link[terra]{values}} function.}

\item{G_mold}{a Raster representing the extent of the projection area.
This is only necessary when G_stack is of class matrix; G_mold will we
use as a mold to save the NT1 values computed by exdet_univa function.}
}
\value{
NT1 metric (univariate extrapolation) as a SpatRaster object.
}
\description{
exdet_univa calculates NT1 metric.
}
\details{
The exdet univariate (\code{\link[smop]{exdet_univar}})
and multivariate (\code{\link[smop]{exdet_multvar}}) is calculated
following: Mesgaran, M.B., Cousens, R.D. & Webber, B.L. (2014)
Here be dragons: a tool for quantifying novelty due to covariate
range and correlation change when projecting species distribution models.
Diversity & Distributions, 20: 1147–1159, DOI: 10.1111/ddi.12209.
}
\examples{
m_calibra <- terra::rast(list.files(system.file("extdata/M_layers",
                                    package = "smop"),
                                    pattern = ".tif$",
                                    full.names = TRUE))
g_transfer <- terra::rast(list.files(system.file("extdata/G_layers",
                                    package = "smop"),
                                    pattern = ".tif$",
                                    full.names = TRUE))

NT1 <- smop::exdet_univar(M_calibra = m_calibra,
                          G_transfer = g_transfer,G_mold=NULL)
terra::plot(NT1)

}
