#' Convert an object to a ggWebGL primitive specification
#'
#' This generic is defined locally so `boids4R` can offer an optional ggWebGL
#' adapter without depending on ggWebGL at load time.
#'
#' @param x Object to convert.
#' @param ... Additional arguments.
#' @return A `ggwebgl_spec` list for supported methods. For a
#'   `boids_simulation`, the list contains point and velocity-vector primitives,
#'   labels, WebGL view settings, selection options, and timeline metadata for
#'   rendering recorded boids frames with `ggWebGL::ggWebGL()`.
#' @examples
#' sim <- boids_scenario("schooling_2d", n = 15, steps = 3, seed = 5)
#'
#' if (requireNamespace("ggWebGL", quietly = TRUE) &&
#'     utils::packageVersion("ggWebGL") >= "0.4.0") {
#'   spec <- as_ggwebgl_spec(sim, vector_every = 10)
#'   names(spec)
#' }
#' @export
as_ggwebgl_spec <- function(x, ...) {
  UseMethod("as_ggwebgl_spec")
}

#' @export
#' @exportS3Method ggWebGL::as_ggwebgl_spec
as_ggwebgl_spec.boids_simulation <- function(x,
                                             every = 1L,
                                             vector_every = 8L,
                                             vector_scale = 0.12,
                                             shader = "density_splat",
                                             ...) {
  require_ggwebgl_adapter()

  frames <- as.data.frame(x)
  every <- as.integer(every)[[1L]]
  vector_every <- as.integer(vector_every)[[1L]]
  if (every > 1L) frames <- frames[frames$frame %% every == 0L, , drop = FALSE]
  palette <- stats::setNames(grDevices::hcl.colors(length(unique(frames$species)), "Dark 3"), sort(unique(frames$species)))
  colours <- unname(palette[frames$species])

  point_layer <- ggWebGL::ggwebgl_layer_points(
    frames,
    x = "x", y = "y", z = "z",
    colour = colours,
    alpha = 0.36,
    size = 2.1,
    id = "id",
    label = "species",
    frame = "frame",
    time = "time"
  )

  vec <- frames[seq(1L, nrow(frames), by = max(1L, vector_every)), , drop = FALSE]
  vec$xend <- vec$x + vec$vx * vector_scale
  vec$yend <- vec$y + vec$vy * vector_scale
  vec$zend <- vec$z + vec$vz * vector_scale
  vector_layer <- ggWebGL::ggwebgl_layer_vectors(
    vec,
    x = "x", y = "y", z = "z",
    xend = "xend", yend = "yend", zend = "zend",
    colour = "#1f2937",
    alpha = 0.58,
    width = 1.1,
    head_size = 6,
    id = "id",
    frame = "frame",
    time = "time"
  )

  ggWebGL::ggwebgl_spec(
    list(point_layer, vector_layer),
    labels = list(
      title = paste("boids4R", x$scenario %||% "simulation"),
      subtitle = "Renderer-neutral boids frames consumed as ggWebGL primitives"
    ),
    webgl = list(
      shader = shader,
      view = ggWebGL::ggwebgl_view(
        dimension = x$dimension,
        projection = if (identical(x$dimension, "3d")) "perspective" else "orthographic",
        controller = if (identical(x$dimension, "3d")) "orbit" else "panzoom",
        state = list(distance = 3.6, yaw = 0.55, pitch = 0.28)
      ),
      selection = ggWebGL::ggwebgl_selection("none"),
      interactions = c("pan", "zoom", "hover")
    ),
    timeline = ggWebGL::ggwebgl_timeline(
      frames = sort(unique(frames$frame)),
      time = sort(unique(frames$time)),
      filter = "exact",
      autoplay = FALSE,
      loop = TRUE,
      speed = 1,
      controls = TRUE
    )
  )
}

ggwebgl_min_version <- "0.4.0"

require_ggwebgl_adapter <- function() {
  if (!requireNamespace("ggWebGL", quietly = TRUE)) {
    stop(
      "The ggWebGL package (>= ", ggwebgl_min_version,
      ") is required for as_ggwebgl_spec.boids_simulation().",
      call. = FALSE
    )
  }

  installed_version <- utils::packageVersion("ggWebGL")
  if (installed_version < ggwebgl_min_version) {
    stop(
      "ggWebGL >= ", ggwebgl_min_version,
      " is required for as_ggwebgl_spec.boids_simulation(); installed version is ",
      as.character(installed_version), ".",
      call. = FALSE
    )
  }

  required_exports <- c(
    "ggwebgl_layer_points",
    "ggwebgl_layer_vectors",
    "ggwebgl_spec",
    "ggwebgl_view",
    "ggwebgl_selection",
    "ggwebgl_timeline"
  )
  missing_exports <- setdiff(required_exports, getNamespaceExports("ggWebGL"))
  if (length(missing_exports) > 0L) {
    stop(
      "The installed ggWebGL package does not export the API required by boids4R: ",
      paste(missing_exports, collapse = ", "), ".",
      call. = FALSE
    )
  }

  invisible(TRUE)
}
