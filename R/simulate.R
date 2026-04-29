#' Simulate boids dynamics
#'
#' @param state Initial `boids_state`.
#' @param world A `boids_world` object.
#' @param params A `boids_params` object.
#' @param steps Number of integration steps.
#' @param dt Time-step size.
#' @param record_every Record every `record_every` steps.
#' @param engine Simulation engine. `rcpp_grid` and `rcpp_naive` are available.
#' @param seed Optional seed for deterministic noise.
#' @return A `boids_simulation` object.
#' @export
simulate_boids <- function(state,
                           world = NULL,
                           params = NULL,
                           steps,
                           dt = 0.05,
                           record_every = 1L,
                           engine = c("rcpp_grid", "rcpp_naive"),
                           seed = NULL) {
  state <- normalise_state(state)
  dimension <- attr(state, "dimension") %||% "2d"
  world <- normalise_world(world, dimension)
  params <- normalise_params(params, dimension)
  engine <- match.arg(engine)
  steps <- as.integer(steps)[[1L]]
  record_every <- as.integer(record_every)[[1L]]
  dt <- positive_number(dt, "dt")
  if (!is.finite(steps) || steps < 0L) stop("`steps` must be a non-negative integer.", call. = FALSE)
  if (!is.finite(record_every) || record_every <= 0L) stop("`record_every` must be a positive integer.", call. = FALSE)
  if (!is.null(seed)) set.seed(seed)

  sim <- boids_simulate_cpp(
    x = state$x,
    y = state$y,
    z = state$z,
    vx = state$vx,
    vy = state$vy,
    vz = state$vz,
    ids = state$id,
    species = state$species,
    bounds = world$bounds,
    boundary = world$boundary,
    obstacles = as_numeric_matrix(world$obstacles, c("x", "y", "z", "radius")),
    attractors = as_numeric_matrix(world$attractors, c("x", "y", "z", "strength")),
    predators = as_numeric_matrix(world$predators, c("x", "y", "z", "radius", "strength")),
    params = unlist(params[setdiff(names(params), "dimension")], use.names = TRUE),
    steps = steps,
    dt = dt,
    record_every = record_every,
    dimension = if (identical(dimension, "3d")) 3L else 2L,
    use_grid = identical(engine, "rcpp_grid")
  )

  out <- list(
    frames = sim,
    params = params,
    world = world,
    initial_state = state,
    engine = engine,
    steps = steps,
    dt = dt,
    record_every = record_every,
    dimension = dimension,
    scenario = attr(state, "scenario") %||% NA_character_
  )
  class(out) <- c("boids_simulation", "list")
  out
}

#' @export
as.data.frame.boids_simulation <- function(x, row.names = NULL, optional = FALSE, ...) {
  x$frames
}

as_numeric_matrix <- function(x, cols) {
  if (is.null(x) || !nrow(x)) return(matrix(numeric(), ncol = length(cols), dimnames = list(NULL, cols)))
  for (nm in setdiff(cols, names(x))) x[[nm]] <- 0
  mat <- as.matrix(x[, cols, drop = FALSE])
  storage.mode(mat) <- "double"
  mat
}
