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

  Optional seed.

- steps:

  Number of simulation steps.

- record_every:

  Record every `record_every` steps.

## Value

A `boids_simulation` object.
