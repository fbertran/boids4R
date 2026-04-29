#' Create initial boids state
#'
#' @param n Number of boids.
#' @param dimension State dimension, either `"2d"` or `"3d"`.
#' @param bounds Optional bounds used for random initialization.
#' @param positions,velocities Optional numeric matrices or data frames.
#' @param species Species labels, recycled to `n`.
#' @param seed Optional seed for reproducible initialization.
#' @return A `boids_state` data frame.
#' @export
boids_state <- function(n,
                        dimension = c("2d", "3d"),
                        bounds = NULL,
                        positions = NULL,
                        velocities = NULL,
                        species = "boid",
                        seed = NULL) {
  dimension <- match.arg(dimension)
  n <- as.integer(n)[[1L]]
  if (!is.finite(n) || n <= 0L) stop("`n` must be a positive integer.", call. = FALSE)
  if (!is.null(seed)) set.seed(seed)
  bounds <- normalise_bounds(bounds, dimension)
  pos <- normalise_state_matrix(positions, n, dimension, bounds, velocity = FALSE)
  vel <- normalise_state_matrix(velocities, n, dimension, bounds, velocity = TRUE)
  species <- rep(as.character(species), length.out = n)
  out <- data.frame(
    id = sprintf("boid-%05d", seq_len(n)),
    species = species,
    x = pos[, 1],
    y = pos[, 2],
    z = pos[, 3],
    vx = vel[, 1],
    vy = vel[, 2],
    vz = vel[, 3],
    stringsAsFactors = FALSE
  )
  attr(out, "dimension") <- dimension
  class(out) <- c("boids_state", "data.frame")
  out
}

normalise_state <- function(state) {
  if (!inherits(state, "boids_state")) {
    state <- as.data.frame(state, stringsAsFactors = FALSE)
    required <- c("id", "species", "x", "y", "vx", "vy")
    missing <- setdiff(required, names(state))
    if (length(missing)) stop("`state` is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
    if (!"z" %in% names(state)) state$z <- 0
    if (!"vz" %in% names(state)) state$vz <- 0
    attr(state, "dimension") <- if (any(abs(state$z) > 0) || any(abs(state$vz) > 0)) "3d" else "2d"
    class(state) <- c("boids_state", "data.frame")
  }
  for (nm in c("x", "y", "z", "vx", "vy", "vz")) state[[nm]] <- as.numeric(state[[nm]])
  state$id <- as.character(state$id)
  state$species <- as.character(state$species)
  state
}

normalise_state_matrix <- function(x, n, dimension, bounds, velocity) {
  if (is.null(x)) {
    if (isTRUE(velocity)) {
      mat <- matrix(stats::rnorm(n * 3L, 0, 0.25), ncol = 3L)
      if (identical(dimension, "2d")) mat[, 3L] <- 0
      return(mat)
    }
    mat <- cbind(
      stats::runif(n, bounds["x", "min"], bounds["x", "max"]),
      stats::runif(n, bounds["y", "min"], bounds["y", "max"]),
      if (identical(dimension, "3d")) stats::runif(n, bounds["z", "min"], bounds["z", "max"]) else rep(0, n)
    )
    return(mat)
  }
  x <- as.matrix(x)
  if (nrow(x) != n) stop("Position/velocity matrix must have `n` rows.", call. = FALSE)
  if (ncol(x) == 2L) x <- cbind(x, 0)
  if (ncol(x) != 3L) stop("Position/velocity matrix must have two or three columns.", call. = FALSE)
  storage.mode(x) <- "double"
  if (identical(dimension, "2d")) x[, 3L] <- 0
  x
}
