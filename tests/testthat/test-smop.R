library(testthat)
library(smop)

test_that("extrapolation_zones, returns an object of class SpatRaster", {
  m_path <- system.file("extdata/M_layers", package = "smop") |>
    list.files(full.names=TRUE)
  g_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  M_calibra <- terra::rast(m_path)
  G_transfer <- terra::rast(g_path)
  extr_zones <- smop::extrapolation_zones(M_calibra = M_calibra,
                                          G_transfer = G_transfer,
                                          as_vec =FALSE)
  testthat::expect_match(class(extr_zones),"SpatRaster")
})

test_that("extrapolation_zones, returns a vector", {
  m_path <- system.file("extdata/M_layers", package = "smop") |>
    list.files(full.names=TRUE)
  g_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  M_calibra <- terra::rast(m_path)
  G_transfer <- terra::rast(g_path)
  extr_zones_ids <- smop::extrapolation_zones(M_calibra = M_calibra,
                                              G_transfer = G_transfer,
                                              as_vec =TRUE)
  testthat::expect_vector(extr_zones_ids)
})

test_that("std_vars, returns an object of class SpatRaster", {
  pred_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  pred <- terra::rast(pred_path)
  std_bios <- smop::std_vars(pred,as_matrix=FALSE)
  testthat::expect_match(class(std_bios),"SpatRaster")
})

test_that("std_vars, returns a matrix of standarized predictors", {
  pred_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  pred <- terra::rast(pred_path)
  std_bios <- smop::std_vars(pred,as_matrix=TRUE)
  testthat::expect_type(std_bios,"double")
})


test_that("mop_distance, returns a numeric vector of Euclidean distance", {
  set.seed(111)
  n=1000
  M <- matrix(rnorm(4*n), 2*n, 2)
  G <- matrix(rnorm(4*n), 2*n, 2)
  mdist <- smop::mop_distance(M,G)
  testthat::expect_vector(mdist)
})

test_that("mop, returns a SpatRaster of MOP distances",{
  # Predictors
  m_path <- system.file("extdata/M_layers", package = "smop") |>
    list.files(full.names=TRUE)
  g_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  M_calibra <- terra::rast(m_path)
  G_transfer <- terra::rast(g_path)
  # Example 1 compute mop distance in serial
  mop_test <- smop::mop(M_calibra = M_calibra, G_transfer =  G_transfer,
                        percent = 20,comp_each = NULL,
                        normalized = TRUE, standardize_vars=TRUE)
  testthat::expect_match(class(mop_test),"SpatRaster")
})


test_that("mop, returns a SpatRaster of MOP distances. It runs in parallel",{
  # Predictors
  m_path <- system.file("extdata/M_layers", package = "smop") |>
    list.files(full.names=TRUE)
  g_path <- system.file("extdata/G_layers", package = "smop") |>
    list.files(full.names=TRUE)
  M_calibra <- terra::rast(m_path)
  G_transfer <- terra::rast(g_path)
  # Example 1 compute mop distance in serial
  future::plan("future::multisession",workers = 2)
  mop_test_parallel <- smop::mop(M_calibra = M_calibra,
                                 G_transfer =  G_transfer,
                                 percent = 20,comp_each = 1500,
                                 normalized = TRUE, standardize_vars=TRUE)
  future::plan("future::sequential")
  testthat::expect_match(class(mop_test_parallel),"SpatRaster")
})
