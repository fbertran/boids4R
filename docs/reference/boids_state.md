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

## Examples

``` r
bounds <- matrix(
  c(-1, -1, 1, 1),
  ncol = 2,
  dimnames = list(c("x", "y"), c("min", "max"))
)
state <- boids_state(6, "2d", bounds = bounds, seed = 1)
head(state)
#>           id species          x          y z          vx           vy vz
#> 1 boid-00001    boid -0.4689827  0.8893505 0  0.12185726 -0.155310145  0
#> 2 boid-00002    boid -0.2557522  0.3215956 0  0.18458118 -0.553674972  0
#> 3 boid-00003    boid  0.1457067  0.2582281 0  0.14394534  0.281232730  0
#> 4 boid-00004    boid  0.8164156 -0.8764275 0 -0.07634710 -0.011233402  0
#> 5 boid-00005    boid -0.5966361 -0.5880509 0  0.37794529 -0.004047566  0
#> 6 boid-00006    boid  0.7967794 -0.6468865 0  0.09746081  0.235959053  0

positions <- matrix(c(-0.5, 0, 0.5, 0), ncol = 2, byrow = TRUE)
velocities <- matrix(c(0.1, 0, -0.1, 0), ncol = 2, byrow = TRUE)
boids_state(2, "2d", positions = positions, velocities = velocities)
#>           id species    x y z   vx vy vz
#> 1 boid-00001    boid -0.5 0 0  0.1  0  0
#> 2 boid-00002    boid  0.5 0 0 -0.1  0  0
```
