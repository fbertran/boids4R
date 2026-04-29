# Create initial boids state

Create initial boids state

## Usage

``` r
boids_state(
  n,
  dimension = c("2d", "3d"),
  bounds = NULL,
  positions = NULL,
  velocities = NULL,
  species = "boid",
  seed = NULL
)
```

## Arguments

- n:

  Number of boids.

- dimension:

  State dimension, either `"2d"` or `"3d"`.

- bounds:

  Optional bounds used for random initialization.

- positions, velocities:

  Optional numeric matrices or data frames.

- species:

  Species labels, recycled to `n`.

- seed:

  Optional seed for reproducible initialization.

## Value

A `boids_state` data frame.
