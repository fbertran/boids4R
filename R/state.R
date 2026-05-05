#' Create initial boids state
#'
#' @param n Number of boids.
#' @param dimension State dimension, either `"2d"` or `"3d"`.
#' @param bounds Optional bounds used for random initialization.
#' @param positions,velocities Optional numeric matrices or data frames.
#' @param species Species labels, recycled to `n`.
#' @param seed Optional integer seed for reproducible initialization. When
#'   supplied, a package-local generator is used and the global R random-number
#'   state is not modified.
#' @param .rng Internal package-local random-number generator.
#' @return A `boids_state` data frame.
#' @examples
#' bounds <- matrix(
#'   c(-1, -1, 1, 1),
#'   ncol = 2,
#'   dimnames = list(c("x", "y"), c("min", "max"))
#' )
#' state <- boids_state(6, "2d", bounds = bounds, seed = 1)
#' head(state)
#'
#' positions <- matrix(c(-0.5, 0, 0.5, 0), ncol = 2, byrow = TRUE)
#' velocities <- matrix(c(0.1, 0, -0.1, 0), ncol = 2, byrow = TRUE)
#' boids_state(2, "2d", positions = positions, velocities = velocities)
#' @export
boids_state <- function(n,
                        dimension = c("2d", "3d"),
                        bounds = NULL,
                        positions = NULL,
                        velocities = NULL,
                        species = "boid",
                        seed = NULL,
                        .rng = NULL) {
  dimension <- match.arg(dimension)
  n <- as.integer(n)[[1L]]
  if (!is.finite(n) || n <= 0L) stop("`n` must be a positive integer.", call. = FALSE)
  rng <- .rng %||% make_boids_rng(seed)
  bounds <- normalise_bounds(bounds, dimension)
  pos <- normalise_state_matrix(positions, n, dimension, bounds, velocity = FALSE, rng = rng)
  vel <- normalise_state_matrix(velocities, n, dimension, bounds, velocity = TRUE, rng = rng)
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

normalise_state_matrix <- function(x, n, dimension, bounds, velocity, rng = NULL) {
  if (is.null(x)) {
    if (isTRUE(velocity)) {
      mat <- matrix(boids_rnorm(n * 3L, 0, 0.25, rng = rng), ncol = 3L)
      if (identical(dimension, "2d")) mat[, 3L] <- 0
      return(mat)
    }
    mat <- cbind(
      boids_runif(n, bounds["x", "min"], bounds["x", "max"], rng = rng),
      boids_runif(n, bounds["y", "min"], bounds["y", "max"], rng = rng),
      if (identical(dimension, "3d")) boids_runif(n, bounds["z", "min"], bounds["z", "max"], rng = rng) else rep(0, n)
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


make_boids_rng <- function(seed = NULL) {
  if (is.null(seed)) return(NULL)
  seed <- as.integer(seed)[[1L]]
  if (!is.finite(seed)) stop("`seed` must be a finite integer.", call. = FALSE)
  
  rng <- new.env(parent = emptyenv())
  rng$modulus <- 2147483647
  rng$multiplier <- 16807
  rng$state <- as.double(seed %% rng$modulus)
  if (rng$state <= 0) rng$state <- rng$state + rng$modulus - 1
  
  rng$runif01 <- function(n) {
    n <- as.integer(n)[[1L]]
    if (!is.finite(n) || n < 0L) stop("`n` must be a non-negative integer.", call. = FALSE)
    out <- numeric(n)
    if (n == 0L) return(out)
    for (i in seq_len(n)) {
      rng$state <- (rng$multiplier * rng$state) %% rng$modulus
      out[i] <- rng$state / rng$modulus
    }
    out
  }
  
  rng
}

boids_runif <- function(n, min = 0, max = 1, rng = NULL) {
  if (is.null(rng)) return(stats::runif(n, min, max))
  min + (max - min) * rng$runif01(n)
}

boids_rnorm <- function(n, mean = 0, sd = 1, rng = NULL) {
  if (is.null(rng)) return(stats::rnorm(n, mean, sd))
  n <- as.integer(n)[[1L]]
  if (!is.finite(n) || n < 0L) stop("`n` must be a non-negative integer.", call. = FALSE)
  if (n == 0L) return(numeric())
  m <- ceiling(n / 2)
  u1 <- pmax(rng$runif01(m), .Machine$double.eps)
  u2 <- rng$runif01(m)
  z1 <- sqrt(-2 * log(u1)) * cos(2 * pi * u2)
  z2 <- sqrt(-2 * log(u1)) * sin(2 * pi * u2)
  mean + sd * c(rbind(z1, z2))[seq_len(n)]
}
