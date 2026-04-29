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

  Optional seed for deterministic noise.

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
#>   frame time         id species          x            y z           vx
#> 1     0    0 boid-00001    boid -0.9379653  0.748091387 0 -0.155310145
#> 2     0    0 boid-00002    boid -0.5115044 -0.463585127 0 -0.553674972
#> 3     0    0 boid-00003    boid  0.2914135  1.079365680 0  0.281232730
#> 4     0    0 boid-00004    boid  1.6328312 -0.009203032 0 -0.011233402
#> 5     0    0 boid-00005    boid -1.1932723  0.870474033 0 -0.004047566
#> 6     0    0 boid-00006    boid  1.5935587  1.967624379 0  0.235959053
#>            vy vz     speed
#> 1  0.15495644  0 0.2193917
#> 2 -0.01403218  0 0.5538528
#> 3 -0.03894888  0 0.2839170
#> 4 -0.36768810  0 0.3678597
#> 5 -0.11953751  0 0.1196060
#> 6  0.10448539  0 0.2580579
```
