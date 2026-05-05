## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## -----------------------------------------------------------------------------
library(boids4R)

sim <- boids_scenario("schooling_2d", n = 80, steps = 20, seed = 12)
frames <- as.data.frame(sim)
head(frames)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace("ggWebGL", quietly = TRUE) &&
#     utils::packageVersion("ggWebGL") >= "0.4.0") {
#   ggWebGL::ggWebGL(as_ggwebgl_spec(sim), height = 440)
# }

## ----eval = FALSE-------------------------------------------------------------
# stopifnot(
#   requireNamespace("ggWebGL", quietly = TRUE),
#   utils::packageVersion("ggWebGL") >= "0.4.0"
# )
# 
# sim <- boids4R::boids_scenario("murmuration_3d", n = 400, steps = 150, seed = 1)
# 
# spec <- boids4R::as_ggwebgl_spec(sim)
# spec$render$timeline$autoplay <- TRUE
# spec$render$timeline$speed <- 2
# 
# w <- ggWebGL::ggWebGL(spec, height = 520)
# 
# htmlwidgets::saveWidget(w, "boids_murmuration.html", selfcontained = FALSE)
# browseURL(normalizePath("boids_murmuration.html"))

## ----eval = FALSE-------------------------------------------------------------
# frames <- as.data.frame(sim)
# keep <- unique(frames$id)[1:120]
# trail <- frames[frames$id %in% keep, ]
# 
# line_layer <- ggWebGL::ggwebgl_layer_lines(
#   trail,
#   x = "x", y = "y", z = "z",
#   group = "id",
#   colour = "#334155",
#   alpha = 0.08,
#   width = 0.7,
#   frame = "frame",
#   time = "time"
# )
# 
# point_layer <- ggWebGL::ggwebgl_layer_points(
#   frames,
#   x = "x", y = "y", z = "z",
#   colour = "#2563eb",
#   alpha = 0.45,
#   size = 2,
#   id = "id",
#   frame = "frame",
#   time = "time"
# )
# 
# spec <- ggWebGL::ggwebgl_spec(
#   list(line_layer, point_layer),
#   webgl = list(
#     view = ggWebGL::ggwebgl_view("3d", controller = "orbit", projection = "perspective")
#   ),
#   timeline = ggWebGL::ggwebgl_timeline(
#     frames = sort(unique(frames$frame)),
#     filter = "cumulative",
#     autoplay = TRUE,
#     speed = 2
#   )
# )
# 
# htmlwidgets::saveWidget(ggWebGL::ggWebGL(spec, height = 520), "boids_trails.html")
# browseURL(normalizePath("boids_trails.html"))

