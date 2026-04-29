# Build boids rule parameters

Build boids rule parameters

## Usage

``` r
boids_params(
  dimension = c("2d", "3d"),
  separation_weight = 1.45,
  alignment_weight = 0.85,
  cohesion_weight = 0.72,
  goal_weight = 0.08,
  obstacle_weight = 1.6,
  predator_weight = 2.2,
  separation_radius = 0.18,
  alignment_radius = 0.46,
  cohesion_radius = 0.64,
  obstacle_radius = 0.38,
  predator_radius = 0.72,
  max_speed = 1.25,
  max_force = 0.075,
  noise = 0.003
)
```

## Arguments

- dimension:

  Simulation dimension, either `"2d"` or `"3d"`.

- separation_weight, alignment_weight, cohesion_weight:

  Rule weights.

- goal_weight, obstacle_weight, predator_weight:

  Optional full-lab forces.

- separation_radius, alignment_radius, cohesion_radius:

  Neighbour radii.

- obstacle_radius, predator_radius:

  Interaction radii for obstacles and predators.

- max_speed, max_force:

  Speed and steering-force limits.

- noise:

  Random steering noise standard deviation.

## Value

A `boids_params` list.

## Examples

``` r
params <- boids_params(
  "2d",
  separation_weight = 1.2,
  alignment_weight = 0.9,
  cohesion_weight = 0.8,
  max_speed = 1.0,
  noise = 0
)
unlist(params[c("separation_weight", "alignment_weight", "max_speed")])
#> separation_weight  alignment_weight         max_speed 
#>               1.2               0.9               1.0 
```
