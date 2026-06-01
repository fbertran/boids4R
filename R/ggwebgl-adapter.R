#' Convert an object to a ggWebGL primitive specification
#'
#' This generic is defined locally so `boids4R` can offer an optional ggWebGL
#' adapter without depending on ggWebGL at load time.
#'
#' @param x Object to convert.
#' @param ... Additional arguments.
#' @param every Integer frame stride used before display layers are built.
#' @param vector_every Integer row stride used when `vector_mode = "sampled"`.
#' @param vector_scale Multiplier applied to velocity components when drawing
#'   velocity arrows.
#' @param shader ggWebGL shader name passed to the specification.
#' @param role_palette Optional named character vector overriding display
#'   colours. Names can include species labels, `species_1`, `species_2`,
#'   `species_3`, `prey`, `predator`, `obstacle`, `attractor`, `vector`, and
#'   `trail`.
#' @param boid_size,prey_size,predator_size Point sizes for ordinary boids and
#'   explicit prey/predator roles.
#' @param current_alpha Alpha for the current-position boid layer.
#' @param trail_alpha Alpha for historical trail points.
#' @param trail Trail rendering mode: `"recent"` shows a moving recent history,
#'   `"none"` omits history, and `"all"` shows all prior positions for each
#'   animation frame.
#' @param trail_length Number of simulation frame units retained when
#'   `trail = "recent"`.
#' @param vector_mode Velocity-arrow mode: `"current"` draws one arrow per boid
#'   at each animation frame, `"sampled"` applies `vector_every`, `"all"` draws
#'   every eligible row, and `"none"` omits arrows.
#' @param vector_colour_mode Velocity-arrow colour policy. `"species"` follows
#'   species colours, `"role"` follows explicit prey/predator role colours when
#'   present and otherwise falls back to species, and `"fixed"` uses
#'   `vector_colour`.
#' @param vector_colour Fixed velocity-arrow colour used when
#'   `vector_colour_mode = "fixed"`.
#' @param vector_alpha,vector_width Alpha and width for velocity arrows.
#' @param obstacle_mode Obstacle rendering mode. `"ring"` draws world-unit
#'   obstacle rings, `"disc"` draws denser concentric rings, and `"none"` omits
#'   obstacle primitives.
#' @param obstacle_segments Number of segments used to approximate each circular
#'   obstacle or predator influence zone.
#' @param obstacle_alpha Alpha for obstacle and predator influence rings.
#' @return A `ggwebgl_spec` list for supported methods. For a
#'   `boids_simulation`, the list contains visible obstacle/predator context
#'   layers when available, faint historical trail points when requested,
#'   emphasized current boid positions, velocity-vector primitives, labels,
#'   WebGL view settings, selection options, and timeline metadata for rendering
#'   recorded boids frames with `ggWebGL::ggWebGL()`.
#' @examples
#' sim <- boids_scenario("schooling_2d", n = 15, steps = 3, seed = 5)
#'
#' if (requireNamespace("ggWebGL", quietly = TRUE) &&
#'     utils::packageVersion("ggWebGL") >= "0.4.0") {
#'   spec <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "current")
#'   names(spec)
#' }
#' @export
as_ggwebgl_spec <- function(x, ...) {
  UseMethod("as_ggwebgl_spec")
}

#' @rdname as_ggwebgl_spec
#' @export
#' @exportS3Method ggWebGL::as_ggwebgl_spec
as_ggwebgl_spec.boids_simulation <- function(x,
                                             every = 1L,
                                             vector_every = 1L,
                                             vector_scale = 0.08,
                                             shader = "density_splat",
                                             role_palette = NULL,
                                             boid_size = 4,
                                             prey_size = 5,
                                             predator_size = 8,
                                             current_alpha = 0.9,
                                             trail_alpha = 0.12,
                                             trail = c("recent", "none", "all"),
                                             trail_length = 30,
                                             vector_mode = c("current", "sampled", "all", "none"),
                                             vector_colour_mode = c("species", "role", "fixed"),
                                             vector_colour = "#334155",
                                             vector_alpha = 0.65,
                                             vector_width = 1.2,
                                             obstacle_mode = c("ring", "disc", "none"),
                                             obstacle_segments = 48,
                                             obstacle_alpha = 0.9,
                                             ...) {
  require_ggwebgl_adapter()

  trail <- match.arg(trail)
  vector_mode <- match.arg(vector_mode)
  vector_colour_mode <- match.arg(vector_colour_mode)
  obstacle_mode <- match.arg(obstacle_mode)

  every <- positive_integer(every, "every")
  vector_every <- positive_integer(vector_every, "vector_every")
  vector_scale <- scalar_number(vector_scale, "vector_scale")
  boid_size <- positive_number(boid_size, "boid_size")
  prey_size <- positive_number(prey_size, "prey_size")
  predator_size <- positive_number(predator_size, "predator_size")
  current_alpha <- alpha_number(current_alpha, "current_alpha")
  trail_alpha <- alpha_number(trail_alpha, "trail_alpha")
  trail_length <- nonnegative_number(trail_length, "trail_length")
  vector_alpha <- alpha_number(vector_alpha, "vector_alpha")
  vector_width <- positive_number(vector_width, "vector_width")
  obstacle_segments <- positive_integer(obstacle_segments, "obstacle_segments")
  obstacle_alpha <- alpha_number(obstacle_alpha, "obstacle_alpha")

  frames <- as.data.frame(x)
  if (every > 1L) frames <- frames[frames$frame %% every == 0L, , drop = FALSE]
  if (!nrow(frames)) stop("No recorded frames are available for ggWebGL export.", call. = FALSE)

  palette <- resolve_display_palette(role_palette)
  frames <- add_display_columns(frames, palette, boid_size, prey_size, predator_size)
  frame_values <- sort(unique(frames$frame))
  frame_time <- stats::setNames(vapply(frame_values, function(frame) {
    time <- frames$time[frames$frame == frame]
    time[[1L]]
  }, numeric(1)), as.character(frame_values))

  layers <- list()
  context_layers <- build_context_layers(x$world, x$dimension, palette, obstacle_mode, obstacle_segments, obstacle_alpha)
  if (length(context_layers)) layers <- c(layers, context_layers)

  trail_rows <- build_trail_rows(frames, trail, trail_length, frame_values, frame_time)
  if (nrow(trail_rows)) {
    trail_size <- pmax(1, trail_rows$.size * 0.55)
    trail_alpha_values <- trail_alpha * pmax(0.25, trail_rows$.age)
    layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_points(
      trail_rows,
      x = "x", y = "y", z = "z",
      colour = trail_rows$.colour,
      alpha = trail_alpha_values,
      size = trail_size,
      age = trail_rows$.age,
      id = "id",
      label = "species",
      frame = "frame",
      time = "time"
    )
  }

  layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_points(
    frames,
    x = "x", y = "y", z = "z",
    colour = frames$.colour,
    alpha = current_alpha,
    size = frames$.size,
    id = "id",
    label = "species",
    frame = "frame",
    time = "time"
  )

  vector_rows <- build_vector_rows(frames, vector_mode, vector_every, vector_scale)
  if (nrow(vector_rows)) {
    vector_colours <- resolve_vector_colours(vector_rows, vector_colour_mode, vector_colour)
    layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_vectors(
      vector_rows,
      x = "x", y = "y", z = "z",
      xend = "xend", yend = "yend", zend = "zend",
      colour = vector_colours,
      alpha = vector_alpha,
      width = vector_width,
      head_size = 6,
      id = "id",
      frame = "frame",
      time = "time"
    )
  }

  ggWebGL::ggwebgl_spec(
    layers,
    labels = list(
      title = paste("boids4R", x$scenario %||% "simulation"),
      subtitle = "Current boids, recent trails, velocity vectors, and world context"
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
      frames = frame_values,
      time = unname(frame_time[as.character(frame_values)]),
      filter = "exact",
      autoplay = FALSE,
      loop = TRUE,
      speed = 1,
      controls = TRUE
    )
  )
}

ggwebgl_min_version <- "0.4.0"

boids_default_palette <- c(
  species_1 = "#2563EB",
  species_2 = "#16A34A",
  species_3 = "#9333EA",
  prey = "#F59E0B",
  predator = "#DC2626",
  obstacle = "#111827",
  attractor = "#0891B2",
  vector = "#334155",
  trail = "#64748B"
)

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
    "ggwebgl_layer_lines",
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

resolve_display_palette <- function(role_palette = NULL) {
  if (is.null(role_palette)) return(boids_default_palette)
  if (is.null(names(role_palette)) || any(!nzchar(names(role_palette)))) {
    stop("`role_palette` must be a named character vector.", call. = FALSE)
  }
  out <- boids_default_palette
  role_palette <- stats::setNames(as.character(role_palette), names(role_palette))
  overlap <- intersect(names(role_palette), names(out))
  out[overlap] <- role_palette[overlap]
  extra <- setdiff(names(role_palette), names(out))
  if (length(extra)) out <- c(out, role_palette[extra])
  out
}

add_display_columns <- function(frames, palette, boid_size, prey_size, predator_size) {
  frames$.role <- detect_frame_roles(frames)
  frames$.species_colour <- map_species_colours(frames$species, palette)
  role_colours <- unname(palette[frames$.role])
  use_role <- !is.na(frames$.role) & !is.na(role_colours)
  frames$.colour <- frames$.species_colour
  frames$.colour[use_role] <- role_colours[use_role]
  frames$.size <- rep(boid_size, nrow(frames))
  frames$.size[identical_role(frames$.role, "prey")] <- prey_size
  frames$.size[identical_role(frames$.role, "predator")] <- predator_size
  frames
}

detect_frame_roles <- function(frames) {
  if ("role" %in% names(frames)) {
    role <- tolower(as.character(frames$role))
    role[!nzchar(role)] <- NA_character_
    return(role)
  }
  species <- tolower(as.character(frames$species))
  role <- rep(NA_character_, length(species))
  role[species %in% c("prey", "predator")] <- species[species %in% c("prey", "predator")]
  role
}

identical_role <- function(role, value) {
  !is.na(role) & role == value
}

map_species_colours <- function(species, palette) {
  species <- as.character(species)
  levels <- sort(unique(species))
  species_keys <- paste0("species_", seq_along(levels))
  available <- unname(palette[species_keys])
  if (length(levels) > length(available) || any(is.na(available[seq_along(levels)]))) {
    extra <- grDevices::hcl.colors(length(levels), "Dark 3")
    available <- rep_len(available, length(levels))
    available[is.na(available)] <- extra[is.na(available)]
  }
  species_map <- stats::setNames(available[seq_along(levels)], levels)
  direct <- unname(palette[levels])
  has_direct <- !is.na(direct)
  species_map[levels[has_direct]] <- direct[has_direct]
  unname(species_map[species])
}

build_trail_rows <- function(frames, trail, trail_length, frame_values, frame_time) {
  if (identical(trail, "none")) return(frames[0, , drop = FALSE])
  rows <- vector("list", length(frame_values))
  for (i in seq_along(frame_values)) {
    frame <- frame_values[[i]]
    keep <- frames$frame < frame
    if (identical(trail, "recent")) keep <- keep & frames$frame >= frame - trail_length
    history <- frames[keep, , drop = FALSE]
    if (!nrow(history)) next
    distance <- frame - history$frame
    history$.source_frame <- history$frame
    history$frame <- frame
    history$time <- unname(frame_time[[as.character(frame)]])
    if (identical(trail, "recent") && trail_length > 0) {
      history$.age <- pmax(0, 1 - distance / max(trail_length, 1))
    } else {
      max_distance <- max(distance)
      history$.age <- if (max_distance > 0) pmax(0, 1 - distance / max_distance) else 1
    }
    rows[[i]] <- history
  }
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (!length(rows)) return(frames[0, , drop = FALSE])
  do.call(rbind, rows)
}

build_vector_rows <- function(frames, vector_mode, vector_every, vector_scale) {
  if (identical(vector_mode, "none")) return(frames[0, , drop = FALSE])
  if (identical(vector_mode, "sampled")) {
    rows <- frames[seq(1L, nrow(frames), by = vector_every), , drop = FALSE]
  } else {
    rows <- frames
  }
  rows$xend <- rows$x + rows$vx * vector_scale
  rows$yend <- rows$y + rows$vy * vector_scale
  rows$zend <- rows$z + rows$vz * vector_scale
  rows
}

resolve_vector_colours <- function(rows, vector_colour_mode, vector_colour) {
  if (identical(vector_colour_mode, "fixed")) return(rep(vector_colour, nrow(rows)))
  if (identical(vector_colour_mode, "role")) {
    role_colour <- rows$.colour
    species_fallback <- is.na(rows$.role)
    role_colour[species_fallback] <- rows$.species_colour[species_fallback]
    return(role_colour)
  }
  rows$.species_colour
}

build_context_layers <- function(world, dimension, palette, obstacle_mode, obstacle_segments, obstacle_alpha) {
  layers <- list()
  if (!identical(obstacle_mode, "none") && !is.null(world$obstacles) && nrow(world$obstacles)) {
    obstacle_rings <- build_circle_rows(
      world$obstacles,
      radius_col = "radius",
      segments = obstacle_segments,
      prefix = "obstacle",
      dense = identical(obstacle_mode, "disc")
    )
    layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_lines(
      obstacle_rings,
      x = "x", y = "y", z = "z",
      group = "group",
      colour = unname(palette[["obstacle"]]),
      alpha = obstacle_alpha,
      width = 1.5
    )
  }

  if (!is.null(world$predators) && nrow(world$predators)) {
    predator_rings <- build_circle_rows(
      world$predators,
      radius_col = "radius",
      segments = obstacle_segments,
      prefix = "predator",
      dense = FALSE
    )
    layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_lines(
      predator_rings,
      x = "x", y = "y", z = "z",
      group = "group",
      colour = unname(palette[["predator"]]),
      alpha = max(0.15, obstacle_alpha * 0.8),
      width = 1.2
    )
  }

  if (!is.null(world$attractors) && nrow(world$attractors)) {
    attractors <- world$attractors
    layers[[length(layers) + 1L]] <- ggWebGL::ggwebgl_layer_points(
      attractors,
      x = "x", y = "y", z = "z",
      colour = unname(palette[["attractor"]]),
      alpha = 0.95,
      size = 6,
      label = rep("attractor", nrow(attractors))
    )
  }

  layers
}

build_circle_rows <- function(points, radius_col, segments, prefix, dense = FALSE) {
  if (!nrow(points)) return(data.frame())
  radii <- if (dense) c(0.35, 0.6, 0.82, 1) else 1
  theta <- seq(0, 2 * pi, length.out = segments + 1L)
  rows <- vector("list", nrow(points) * length(radii))
  k <- 0L
  for (i in seq_len(nrow(points))) {
    radius <- points[[radius_col]][[i]]
    for (scale in radii) {
      k <- k + 1L
      rows[[k]] <- data.frame(
        x = points$x[[i]] + cos(theta) * radius * scale,
        y = points$y[[i]] + sin(theta) * radius * scale,
        z = points$z[[i]],
        group = paste(prefix, i, scale, sep = "-"),
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

positive_integer <- function(x, name) {
  out <- as.integer(x)[[1L]]
  if (!is.finite(out) || out <= 0L) stop("`", name, "` must be a positive integer.", call. = FALSE)
  out
}

alpha_number <- function(x, name) {
  out <- scalar_number(x, name)
  if (out < 0 || out > 1) stop("`", name, "` must be between 0 and 1.", call. = FALSE)
  out
}
