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
