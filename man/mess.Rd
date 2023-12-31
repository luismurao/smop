% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mess.R
\name{mess}
\alias{mess}
\title{mess: Multivariate Environmental Similarity Surface (MESS)}
\usage{
mess(M_calibra, G_transfer)
}
\arguments{
\item{M_calibra}{A SpatRaster or a Matrix of variables representing the
calibration area (M area in ENM context). If M_stack is matrix it should
contain the values of environmental variables as get it from
\code{\link[terra]{values}} function.}

\item{G_transfer}{A SpatRaster or a Matrix of variables representing areas
or scenarios to which models will be transferred. If G_stack is matrix it
should contain the values of environmental variables as get it from
\code{\link[terra]{values}} function.}
}
\value{
A SpatRaster or a matrix with MESS values
}
\description{
mess calculates multivariate environmental similarity surfaces
as described by Elith et al., (2010) and optimized from the
mess function of the dismo-package.
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

messVals <- smop::mess(M_calibra = m_calibra,
                       G_transfer = g_transfer)
terra::plot(messVals)
}
\references{
Elith J., M. Kearney M., and S. Phillips, 2010. The art of
modelling range-shifting species. Methods in Ecology and
Evolution 1:330-342.
}
