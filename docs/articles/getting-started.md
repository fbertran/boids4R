# Getting Started with boids4R

`boids4R` simulates flocking and swarm dynamics in R. The core objects
are renderer-neutral: they describe boids, rules, worlds, and recorded
frames.

``` r
library(boids4R)

sim <- boids_scenario("schooling_2d", n = 80, steps = 20, seed = 12)
frames <- as.data.frame(sim)
head(frames)
#>   frame time         id species         x          y z           vx          vy
#> 1     0    0 boid-00001    boid -1.894812  0.1212369 0  0.001064510 -0.42168526
#> 2     0    0 boid-00002    boid  1.398211  1.0956112 0 -0.318514888  0.31179245
#> 3     0    0 boid-00003    boid  1.947536 -1.0908581 0 -0.050527585 -0.44254822
#> 4     0    0 boid-00004    boid -1.014720 -0.7459710 0  0.291116470  0.05570897
#> 5     0    0 boid-00005    boid -1.454868  0.6333988 0 -0.005844852 -0.14013011
#> 6     0    0 boid-00006    boid -2.050859 -0.6898092 0  0.224289187 -0.12703239
#>   vz     speed
#> 1  0 0.4216866
#> 2  0 0.4457199
#> 3  0 0.4454234
#> 4  0 0.2963989
#> 5  0 0.1402520
#> 6  0 0.2577651
```

The same frame table can be handed to visualization packages. If
`ggWebGL` is installed, the optional adapter creates point and
velocity-vector primitives with exact timeline controls.

``` r
if (requireNamespace("ggWebGL", quietly = TRUE)) {
  ggWebGL::ggWebGL(as_ggwebgl_spec(sim), height = 440)
}
```

For larger examples, see the scenario gallery and custom simulation
workflow vignettes. They show obstacle corridors, predator avoidance,
parameter sweeps, and mixed-species 3D runs using the same
renderer-neutral frame output.

To generate a standalone WebGL page for an external browser:

``` r
sim <- boids4R::boids_scenario("murmuration_3d", n = 400, steps = 150, seed = 1)

spec <- boids4R::as_ggwebgl_spec(sim)
spec$render$timeline$autoplay <- TRUE
spec$render$timeline$speed <- 2

w <- ggWebGL::ggWebGL(spec, height = 520)

htmlwidgets::saveWidget(w, "boids_murmuration.html", selfcontained = FALSE)
browseURL(normalizePath("boids_murmuration.html"))
```

To see trajectories, not only moving current positions, use cumulative
line trails:

``` r
frames <- as.data.frame(sim)
keep <- unique(frames$id)[1:120]
trail <- frames[frames$id %in% keep, ]

line_layer <- ggWebGL::ggwebgl_layer_lines(
  trail,
  x = "x", y = "y", z = "z",
  group = "id",
  colour = "#334155",
  alpha = 0.08,
  width = 0.7,
  frame = "frame",
  time = "time"
)

point_layer <- ggWebGL::ggwebgl_layer_points(
  frames,
  x = "x", y = "y", z = "z",
  colour = "#2563eb",
  alpha = 0.45,
  size = 2,
  id = "id",
  frame = "frame",
  time = "time"
)

spec <- ggWebGL::ggwebgl_spec(
  list(line_layer, point_layer),
  webgl = list(
    view = ggWebGL::ggwebgl_view("3d", controller = "orbit", projection = "perspective")
  ),
  timeline = ggWebGL::ggwebgl_timeline(
    frames = sort(unique(frames$frame)),
    filter = "cumulative",
    autoplay = TRUE,
    speed = 2
  )
)

htmlwidgets::saveWidget(ggWebGL::ggWebGL(spec, height = 520), "boids_trails.html")
browseURL(normalizePath("boids_trails.html"))
```
