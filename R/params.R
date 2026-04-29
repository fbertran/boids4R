#' Build boids rule parameters
#'
#' @param dimension Simulation dimension, either `"2d"` or `"3d"`.
#' @param separation_weight,alignment_weight,cohesion_weight Rule weights.
#' @param goal_weight,obstacle_weight,predator_weight Optional full-lab forces.
#' @param separation_radius,alignment_radius,cohesion_radius Neighbour radii.
#' @param obstacle_radius,predator_radius Interaction radii for obstacles and predators.
#' @param max_speed,max_force Speed and steering-force limits.
#' @param noise Random steering noise standard deviation.
#' @return A `boids_params` list.
#' @export
boids_params <- function(dimension = c("2d", "3d"),
                         separation_weight = 1.45,
                         alignment_weight = 0.85,
                         cohesion_weight = 0.72,
                         goal_weight = 0.08,
                         obstacle_weight = 1.6,
                         predator_weight = 2.2,
                         separation_radius = 0.18,
                         alignment_radius = 0.46,
                         cohesion_radius = 0.64,
                         obstacle_radius = 0.38,
                         predator_radius = 0.72,
                         max_speed = 1.25,
                         max_force = 0.075,
                         noise = 0.003) {
  dimension <- match.arg(dimension)
  out <- list(
    dimension = dimension,
    separation_weight = scalar_number(separation_weight, "separation_weight"),
    alignment_weight = scalar_number(alignment_weight, "alignment_weight"),
    cohesion_weight = scalar_number(cohesion_weight, "cohesion_weight"),
    goal_weight = scalar_number(goal_weight, "goal_weight"),
    obstacle_weight = scalar_number(obstacle_weight, "obstacle_weight"),
    predator_weight = scalar_number(predator_weight, "predator_weight"),
    separation_radius = positive_number(separation_radius, "separation_radius"),
    alignment_radius = positive_number(alignment_radius, "alignment_radius"),
    cohesion_radius = positive_number(cohesion_radius, "cohesion_radius"),
    obstacle_radius = positive_number(obstacle_radius, "obstacle_radius"),
    predator_radius = positive_number(predator_radius, "predator_radius"),
    max_speed = positive_number(max_speed, "max_speed"),
    max_force = positive_number(max_force, "max_force"),
    noise = nonnegative_number(noise, "noise")
  )
  class(out) <- c("boids_params", "list")
  out
}

normalise_params <- function(params, dimension = NULL) {
  if (is.null(params)) {
    return(boids_params(dimension = dimension %||% "2d"))
  }
  if (!inherits(params, "boids_params")) {
    stop("`params` must be created by boids_params().", call. = FALSE)
  }
  if (!is.null(dimension) && !identical(params$dimension, dimension)) {
    params$dimension <- dimension
  }
  params
}
