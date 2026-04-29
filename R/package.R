#' boids4R: Reynolds-style boids and swarm simulation for R
#'
#' `boids4R` owns simulation state and frame generation. Visualization packages
#' can consume exported frames or optional adapters, but core `boids4R` objects
#' do not contain renderer-specific camera, scene, shader, or widget fields.
#'
#' @keywords internal
#' @useDynLib boids4R, .registration = TRUE
#' @importFrom Rcpp sourceCpp
"_PACKAGE"

NULL
