# Convert an object to a ggWebGL primitive specification

This generic is defined locally so `boids4R` can offer an optional
ggWebGL adapter without depending on ggWebGL at load time.

## Usage

``` r
as_ggwebgl_spec(x, ...)

# S3 method for class 'boids_simulation'
as_ggwebgl_spec(
  x,
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
  ...
)
```

## Arguments

- x:

  Object to convert.

- ...:

  Additional arguments.

- every:

  Integer frame stride used before display layers are built.

- vector_every:

  Integer row stride used when `vector_mode = "sampled"`.

- vector_scale:

  Multiplier applied to velocity components when drawing velocity
  arrows.

- shader:

  ggWebGL shader name passed to the specification.

- role_palette:

  Optional named character vector overriding display colours. Names can
  include species labels, `species_1`, `species_2`, `species_3`, `prey`,
  `predator`, `obstacle`, `attractor`, `vector`, and `trail`.

- boid_size, prey_size, predator_size:

  Point sizes for ordinary boids and explicit prey/predator roles.

- current_alpha:

  Alpha for the current-position boid layer.

- trail_alpha:

  Alpha for historical trail points.

- trail:

  Trail rendering mode: `"recent"` shows a moving recent history,
  `"none"` omits history, and `"all"` shows all prior positions for each
  animation frame.

- trail_length:

  Number of simulation frame units retained when `trail = "recent"`.

- vector_mode:

  Velocity-arrow mode: `"current"` draws one arrow per boid at each
  animation frame, `"sampled"` applies `vector_every`, `"all"` draws
  every eligible row, and `"none"` omits arrows.

- vector_colour_mode:

  Velocity-arrow colour policy. `"species"` follows species colours,
  `"role"` follows explicit prey/predator role colours when present and
  otherwise falls back to species, and `"fixed"` uses `vector_colour`.

- vector_colour:

  Fixed velocity-arrow colour used when `vector_colour_mode = "fixed"`.

- vector_alpha, vector_width:

  Alpha and width for velocity arrows.

- obstacle_mode:

  Obstacle rendering mode. `"ring"` draws world-unit obstacle rings,
  `"disc"` draws denser concentric rings, and `"none"` omits obstacle
  primitives.

- obstacle_segments:

  Number of segments used to approximate each circular obstacle or
  predator influence zone.

- obstacle_alpha:

  Alpha for obstacle and predator influence rings.

## Value

A `ggwebgl_spec` list for supported methods. For a `boids_simulation`,
the list contains visible obstacle/predator context layers when
available, faint historical trail points when requested, emphasized
current boid positions, velocity-vector primitives, labels, WebGL view
settings, selection options, and timeline metadata for rendering
recorded boids frames with
[`ggWebGL::ggWebGL()`](https://fbertran.github.io/ggWebGL/reference/ggWebGL.html).

## Examples

``` r
sim <- boids_scenario("schooling_2d", n = 15, steps = 3, seed = 5)

if (requireNamespace("ggWebGL", quietly = TRUE) &&
    utils::packageVersion("ggWebGL") >= "0.4.0") {
  spec <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "current")
  names(spec)
}
#> [1] "scene_version"   "package_version" "labels"          "webgl"          
#> [5] "layer_count"     "layers"          "render"         
```
