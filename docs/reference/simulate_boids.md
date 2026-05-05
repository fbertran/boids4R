# Simulate boids dynamics

Simulate boids dynamics

## Usage

``` r
simulate_boids(
  state,
  world = NULL,
  params = NULL,
  steps,
  dt = 0.05,
  record_every = 1L,
  engine = c("rcpp_grid", "rcpp_naive"),
  seed = NULL
)
```

## Arguments

- state:

  Initial `boids_state`.

- world:

  A `boids_world` object.

- params:

  A `boids_params` object.

- steps:

  Number of integration steps.

- dt:

  Time-step size.

- record_every:

  Record every `record_every` steps.

- engine:

  Simulation engine. `rcpp_grid` and `rcpp_naive` are available.

- seed:

  Optional integer seed for deterministic noise. When supplied, the
  global R random-number state is not modified.

## Value

A `boids_simulation` object.

## Examples

``` r
state <- boids_state(12, "2d", seed = 1)
world <- boids_world(
  "2d",
  boundary = "reflect",
  attractors = data.frame(x = 0.8, y = 0.2, strength = 0.3)
)
params <- boids_params("2d", max_speed = 0.9, noise = 0)
sim <- simulate_boids(
  state,
  world,
  params,
  steps = 4,
  record_every = 2,
  seed = 2
)
head(as.data.frame(sim))
#>   frame time         id species          x          y z           vx
#> 1     0    0 boid-00001    boid -1.9999687  1.3238614 0 -0.024700034
#> 2     0    0 boid-00002    boid -1.4738488 -1.8617116 0 -0.142371844
#> 3     0    0 boid-00003    boid  1.0224213 -1.7861535 0  0.005966604
#> 4     0    0 boid-00004    boid -0.1653995  0.1188008 0 -0.282932210
#> 5     0    0 boid-00005    boid  0.1310689  0.6845975 0 -0.316795802
#> 6     0    0 boid-00006    boid -1.1241633 -1.9692073 0 -0.444897707
#>            vy vz      speed
#> 1 -0.01541146  0 0.02911365
#> 2  0.10727189  0 0.17826105
#> 3 -0.16972742  0 0.16983226
#> 4  0.07166737  0 0.29186786
#> 5  0.04230388  0 0.31960788
#> 6 -0.40671955  0 0.60278915
```
