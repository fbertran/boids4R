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
  seed = NULL,
  .rng = NULL
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

  Optional integer seed for reproducible initialization. When supplied,
  a package-local generator is used and the global R random-number state
  is not modified.

- .rng:

  Internal package-local random-number generator.

## Value

A `boids_state` data frame.

## Examples

``` r
bounds <- matrix(
  c(-1, -1, 1, 1),
  ncol = 2,
  dimnames = list(c("x", "y"), c("min", "max"))
)
state <- boids_state(6, "2d", bounds = bounds, seed = 1)
head(state)
#>           id species           x           y z          vx          vy vz
#> 1 boid-00001    boid -0.99998435 -0.90591077 0 -0.05886229  0.16011908  0
#> 2 boid-00002    boid -0.73692442  0.35772943 0 -0.14028945 -0.23193187  0
#> 3 boid-00003    boid  0.51121064  0.35859281 0 -0.54979332 -0.22007277  0
#> 4 boid-00004    boid -0.08269974  0.86938579 0 -0.34397065 -0.03759543  0
#> 5 boid-00005    boid  0.06553447 -0.23299585 0  0.54818010  0.65333705  0
#> 6 boid-00006    boid -0.56208163  0.03883274 0 -0.25612000  0.42602467  0

positions <- matrix(c(-0.5, 0, 0.5, 0), ncol = 2, byrow = TRUE)
velocities <- matrix(c(0.1, 0, -0.1, 0), ncol = 2, byrow = TRUE)
boids_state(2, "2d", positions = positions, velocities = velocities)
#>           id species    x y z   vx vy vz
#> 1 boid-00001    boid -0.5 0 0  0.1  0  0
#> 2 boid-00002    boid  0.5 0 0 -0.1  0  0
```
