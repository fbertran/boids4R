# Build a boids simulation world

Build a boids simulation world

## Usage

``` r
boids_world(
  dimension = c("2d", "3d"),
  bounds = NULL,
  boundary = c("wrap", "reflect", "open"),
  obstacles = NULL,
  attractors = NULL,
  predators = NULL,
  species = NULL
)
```

## Arguments

- dimension:

  World dimension, either `"2d"` or `"3d"`.

- bounds:

  Numeric matrix with rows `x`, `y`, and optionally `z`, and columns
  `min` and `max`.

- boundary:

  Boundary behavior: `wrap`, `reflect`, or `open`.

- obstacles, attractors, predators:

  Data frames with coordinate columns.

- species:

  Optional species definition table.

## Value

A `boids_world` list.

## Examples

``` r
bounds <- matrix(
  c(-2, -1, 2, 1),
  ncol = 2,
  dimnames = list(c("x", "y"), c("min", "max"))
)
world <- boids_world(
  "2d",
  bounds = bounds,
  boundary = "reflect",
  obstacles = data.frame(x = 0, y = 0, radius = 0.25),
  attractors = data.frame(x = 1.5, y = 0.4, strength = 0.5)
)
world$boundary
#> [1] "reflect"
world$obstacles
#>   x y radius z
#> 1 0 0   0.25 0
```
