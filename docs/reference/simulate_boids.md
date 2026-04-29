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
