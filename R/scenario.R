#' Generate and simulate a named boids scenario
#'
#' @param name Scenario name.
#' @param n Number of boids.
#' @param dimension Scenario dimension. Some scenario names imply a dimension.
#' @param seed Optional seed.
#' @param steps Number of simulation steps.
#' @param record_every Record every `record_every` steps.
#' @return A `boids_simulation` object.
#' @export
boids_scenario <- function(name = c("murmuration_3d", "predator_avoidance_2d", "obstacle_corridor_2d", "schooling_2d", "mixed_species_3d"),
                           n = 500L,
                           dimension = c("2d", "3d"),
                           seed = NULL,
                           steps = 120L,
                           record_every = 2L) {
  name <- match.arg(name)
  dimension <- if (grepl("_3d$", name)) "3d" else if (grepl("_2d$", name)) "2d" else match.arg(dimension)
  if (!is.null(seed)) set.seed(seed)
  bounds <- if (identical(dimension, "3d")) {
    matrix(c(-2.2, -1.5, -1.2, 2.2, 1.5, 1.2), ncol = 2L, dimnames = list(c("x", "y", "z"), c("min", "max")))
  } else {
    matrix(c(-2.2, -1.45, 2.2, 1.45), ncol = 2L, dimnames = list(c("x", "y"), c("min", "max")))
  }

  species <- switch(name,
    mixed_species_3d = rep(c("swift", "tern", "kite"), length.out = n),
    predator_avoidance_2d = rep(c("school", "scout"), length.out = n),
    rep("boid", n)
  )

  world <- switch(name,
    predator_avoidance_2d = boids_world(
      dimension = dimension,
      bounds = bounds,
      boundary = "reflect",
      predators = data.frame(x = c(-0.8, 1.1), y = c(0.6, -0.35), radius = c(0.9, 0.72), strength = c(1.25, 1.05))
    ),
    obstacle_corridor_2d = boids_world(
      dimension = dimension,
      bounds = bounds,
      boundary = "reflect",
      obstacles = data.frame(x = c(-0.7, 0.0, 0.7), y = c(0.55, -0.35, 0.45), radius = c(0.35, 0.42, 0.35)),
      attractors = data.frame(x = 1.85, y = -1.0, strength = 0.65)
    ),
    schooling_2d = boids_world(
      dimension = dimension,
      bounds = bounds,
      boundary = "wrap",
      attractors = data.frame(x = 0.9, y = 0.2, strength = 0.28)
    ),
    mixed_species_3d = boids_world(
      dimension = dimension,
      bounds = bounds,
      boundary = "wrap",
      predators = data.frame(x = 0.0, y = 0.0, z = 0.6, radius = 0.75, strength = 0.9)
    ),
    boids_world(dimension = dimension, bounds = bounds, boundary = "wrap", attractors = data.frame(x = 0, y = 0, z = 0, strength = 0.12))
  )

  positions <- if (identical(name, "obstacle_corridor_2d")) {
    sample_positions_outside_obstacles(n, dimension, bounds, world$obstacles, buffer = 0.08)
  } else {
    NULL
  }

  state <- boids_state(n, dimension = dimension, bounds = bounds, positions = positions, species = species, seed = seed)
  attr(state, "scenario") <- name

  params <- switch(name,
    predator_avoidance_2d = boids_params(dimension, predator_weight = 2.9, cohesion_weight = 0.62, max_speed = 1.35),
    obstacle_corridor_2d = boids_params(dimension, obstacle_weight = 2.5, goal_weight = 0.22, max_speed = 1.15),
    schooling_2d = boids_params(dimension, cohesion_weight = 0.92, alignment_weight = 1.05, separation_weight = 1.15),
    mixed_species_3d = boids_params(dimension, cohesion_radius = 0.72, alignment_radius = 0.52, max_speed = 1.3),
    boids_params(dimension, cohesion_weight = 0.85, alignment_weight = 1.0, noise = 0.002)
  )

  simulate_boids(state, world, params, steps = steps, record_every = record_every, seed = seed)
}

sample_positions_outside_obstacles <- function(n, dimension, bounds, obstacles, buffer = 0) {
  if (is.null(obstacles) || !nrow(obstacles)) return(NULL)

  dims <- if (identical(dimension, "3d")) c("x", "y", "z") else c("x", "y")
  out <- matrix(NA_real_, nrow = n, ncol = length(dims), dimnames = list(NULL, dims))
  filled <- 0L
  attempts <- 0L

  while (filled < n && attempts < 100L) {
    attempts <- attempts + 1L
    batch <- max(50L, (n - filled) * 4L)
    candidates <- cbind(
      x = stats::runif(batch, bounds["x", "min"], bounds["x", "max"]),
      y = stats::runif(batch, bounds["y", "min"], bounds["y", "max"])
    )
    if (identical(dimension, "3d")) {
      candidates <- cbind(candidates, z = stats::runif(batch, bounds["z", "min"], bounds["z", "max"]))
    }

    keep <- rep(TRUE, batch)
    for (i in seq_len(nrow(obstacles))) {
      radius <- obstacles$radius[i]
      if (!is.finite(radius) || radius < 0) radius <- 0
      dx <- candidates[, "x"] - obstacles$x[i]
      dy <- candidates[, "y"] - obstacles$y[i]
      dz <- if (identical(dimension, "3d")) candidates[, "z"] - obstacles$z[i] else rep(0, batch)
      keep <- keep & sqrt(dx * dx + dy * dy + dz * dz) >= radius + buffer
    }

    candidates <- candidates[keep, , drop = FALSE]
    take <- min(n - filled, nrow(candidates))
    if (take > 0L) {
      out[filled + seq_len(take), ] <- candidates[seq_len(take), , drop = FALSE]
      filled <- filled + take
    }
  }

  if (filled < n) {
    stop("Could not initialize the scenario outside obstacle discs.", call. = FALSE)
  }
  out
}
