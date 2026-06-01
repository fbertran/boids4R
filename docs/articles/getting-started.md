# Getting Started with boids4R

`boids4R` simulates flocking and swarm dynamics in R. The core objects
are renderer-neutral: they describe boids, rules, worlds, and recorded
frames.

``` r
library(boids4R)

sim <- boids_scenario("schooling_2d", n = 80, steps = 20, seed = 12)
frames <- as.data.frame(sim)
head(frames)
#>   frame time         id species           x           y z          vx
#> 1     0    0 boid-00001    boid -2.19958677  1.25804205 0 -0.02683391
#> 2     0    0 boid-00002    boid  0.34519521  0.01271507 0  0.05059609
#> 3     0    0 boid-00003    boid -1.90403899 -0.89780400 0  0.13404070
#> 4     0    0 boid-00004    boid  0.01672697 -0.69175552 0  0.15357851
#> 5     0    0 boid-00005    boid -0.46988986 -0.23499981 0 -0.07141984
#> 6     0    0 boid-00006    boid  0.56104504  0.15811094 0  0.21125602
#>            vy vz      speed
#> 1  0.02341728  0 0.03561499
#> 2 -0.40515990  0 0.40830688
#> 3 -0.13518897  0 0.19037586
#> 4 -0.29706520  0 0.33441604
#> 5  0.09770255  0 0.12102306
#> 6 -0.10675316  0 0.23669674
```

The same frame table can be handed to visualization packages. If
`ggWebGL` 0.4.0 or later is installed, the optional adapter emphasizes
current boids, keeps recent positions as faint trails, colours species
and explicit prey/predator roles distinctly, draws velocity vectors in
species colours by default, and includes visible rings for obstacles and
predator influence zones.

``` r
if (requireNamespace("ggWebGL", quietly = TRUE) &&
    utils::packageVersion("ggWebGL") >= "0.4.0") {
  ggWebGL::ggWebGL(as_ggwebgl_spec(sim, trail_length = 30), height = 440)
}
```

For larger examples, see the scenario gallery and custom simulation
workflow vignettes. They show obstacle corridors, predator avoidance,
parameter sweeps, and mixed-species 3D runs using the same
renderer-neutral frame output.

To generate a standalone WebGL page for an external browser:

``` r
stopifnot(
  requireNamespace("ggWebGL", quietly = TRUE),
  utils::packageVersion("ggWebGL") >= "0.4.0"
)

sim <- boids4R::boids_scenario("murmuration_3d", n = 400, steps = 240, seed = 1)

spec <- boids4R::as_ggwebgl_spec(sim, trail_length = 30)
spec$render$timeline$autoplay <- TRUE
spec$render$timeline$speed <- 2

w <- ggWebGL::ggWebGL(spec, height = 520)

outfile <- file.path(tempdir(), "boids_murmuration.html")
htmlwidgets::saveWidget(w, outfile, selfcontained = FALSE)
browseURL(outfile)
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

outfile <- file.path(tempdir(), "boids_trails.html")
htmlwidgets::saveWidget(ggWebGL::ggWebGL(spec, height = 520), outfile)
browseURL(outfile)
```
