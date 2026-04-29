`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

scalar_number <- function(x, name) {
  x <- as.numeric(x)[[1L]]
  if (!is.finite(x)) stop("`", name, "` must be finite.", call. = FALSE)
  x
}

positive_number <- function(x, name) {
  x <- scalar_number(x, name)
  if (x <= 0) stop("`", name, "` must be positive.", call. = FALSE)
  x
}

nonnegative_number <- function(x, name) {
  x <- scalar_number(x, name)
  if (x < 0) stop("`", name, "` must be non-negative.", call. = FALSE)
  x
}
