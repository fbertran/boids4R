# Generate and simulate a named boids scenario

Generate and simulate a named boids scenario

## Usage

``` r
boids_scenario(
  name = c("murmuration_3d", "predator_avoidance_2d", "obstacle_corridor_2d",
    "schooling_2d", "mixed_species_3d"),
  n = 500L,
  dimension = c("2d", "3d"),
  seed = NULL,
  steps = 120L,
  record_every = 2L
)
```

## Arguments

- name:

  Scenario name.

- n:

  Number of boids.

- dimension:

  Scenario dimension. Some scenario names imply a dimension.

- seed:

  Optional integer seed for reproducible scenario initialization and
  simulation noise. When supplied, the global R random-number state is
  not modified.

- steps:

  Number of simulation steps.

- record_every:

  Record every `record_every` steps.

## Value

A `boids_simulation` object.

## Examples

``` r
sim <- boids_scenario(
  "schooling_2d",
  n = 20,
  steps = 5,
  record_every = 1,
  seed = 3
)
frames <- as.data.frame(sim)
table(frames$frame)
#> 
#>  0  1  2  3  4  5 
#> 20 20 20 20 20 20 

sim3d <- boids_scenario("murmuration_3d", n = 15, steps = 3, seed = 4)
range(as.data.frame(sim3d)$z)
#> [1] -1.186552  1.175857
```
