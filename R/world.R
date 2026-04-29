#' Build a boids simulation world
#'
#' @param dimension World dimension, either `"2d"` or `"3d"`.
#' @param bounds Numeric matrix with rows `x`, `y`, and optionally `z`, and
#'   columns `min` and `max`.
#' @param boundary Boundary behavior: `wrap`, `reflect`, or `open`.
#' @param obstacles,attractors,predators Data frames with coordinate columns.
#' @param species Optional species definition table.
#' @return A `boids_world` list.
#' @examples
#' bounds <- matrix(
#'   c(-2, -1, 2, 1),
#'   ncol = 2,
#'   dimnames = list(c("x", "y"), c("min", "max"))
#' )
#' world <- boids_world(
#'   "2d",
#'   bounds = bounds,
#'   boundary = "reflect",
#'   obstacles = data.frame(x = 0, y = 0, radius = 0.25),
#'   attractors = data.frame(x = 1.5, y = 0.4, strength = 0.5)
#' )
#' world$boundary
#' world$obstacles
#' @export
boids_world <- function(dimension = c("2d", "3d"),
                        bounds = NULL,
                        boundary = c("wrap", "reflect", "open"),
                        obstacles = NULL,
                        attractors = NULL,
                        predators = NULL,
                        species = NULL) {
  dimension <- match.arg(dimension)
  boundary <- match.arg(boundary)
  bounds <- normalise_bounds(bounds, dimension)
  out <- list(
    dimension = dimension,
    bounds = bounds,
    boundary = boundary,
    obstacles = normalise_points_table(obstacles, dimension, value_cols = c("radius")),
    attractors = normalise_points_table(attractors, dimension, value_cols = c("strength")),
    predators = normalise_points_table(predators, dimension, value_cols = c("radius", "strength")),
    species = normalise_species(species)
  )
  class(out) <- c("boids_world", "list")
  out
}

normalise_world <- function(world, dimension = NULL) {
  if (is.null(world)) {
    return(boids_world(dimension = dimension %||% "2d"))
  }
  if (!inherits(world, "boids_world")) {
    stop("`world` must be created by boids_world().", call. = FALSE)
  }
  if (!is.null(dimension) && !identical(world$dimension, dimension)) {
    stop("`world` dimension does not match the simulation state.", call. = FALSE)
  }
  world
}

normalise_bounds <- function(bounds, dimension) {
  dims <- if (identical(dimension, "3d")) c("x", "y", "z") else c("x", "y")
  if (is.null(bounds)) {
    bounds <- matrix(c(rep(-2, length(dims)), rep(2, length(dims))), ncol = 2)
    rownames(bounds) <- dims
    colnames(bounds) <- c("min", "max")
    return(bounds)
  }
  bounds <- as.matrix(bounds)
  if (ncol(bounds) != 2L) {
    stop("`bounds` must have two columns: min and max.", call. = FALSE)
  }
  if (is.null(rownames(bounds))) {
    rownames(bounds) <- dims[seq_len(nrow(bounds))]
  }
  bounds <- bounds[dims, , drop = FALSE]
  storage.mode(bounds) <- "double"
  colnames(bounds) <- c("min", "max")
  if (any(!is.finite(bounds)) || any(bounds[, "min"] >= bounds[, "max"])) {
    stop("`bounds` must contain finite min values smaller than max values.", call. = FALSE)
  }
  bounds
}

normalise_points_table <- function(x, dimension, value_cols = character()) {
  dims <- c("x", "y", "z")
  needed <- if (identical(dimension, "3d")) dims else dims[1:2]
  if (is.null(x)) {
    out <- as.data.frame(stats::setNames(rep(list(numeric()), length(c(needed, value_cols))), c(needed, value_cols)))
    if (!"z" %in% names(out)) out$z <- numeric()
    return(out)
  }
  x <- as.data.frame(x, stringsAsFactors = FALSE)
  missing <- setdiff(needed, names(x))
  if (length(missing)) {
    stop("Point table is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (!"z" %in% names(x)) x$z <- 0
  for (nm in c("x", "y", "z", intersect(value_cols, names(x)))) {
    x[[nm]] <- as.numeric(x[[nm]])
  }
  for (nm in setdiff(value_cols, names(x))) {
    x[[nm]] <- if (identical(nm, "strength")) 1 else 0.2
  }
  x
}

normalise_species <- function(species) {
  if (is.null(species)) {
    return(data.frame(species = "boid", max_speed = 1.25, stringsAsFactors = FALSE))
  }
  species <- as.data.frame(species, stringsAsFactors = FALSE)
  if (!"species" %in% names(species)) {
    stop("`species` must contain a `species` column.", call. = FALSE)
  }
  species
}
