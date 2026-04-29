# Convert an object to a ggWebGL primitive specification

This generic is defined locally so `boids4R` can offer an optional
ggWebGL adapter without depending on ggWebGL at load time.

## Usage

``` r
as_ggwebgl_spec(x, ...)
```

## Arguments

- x:

  Object to convert.

- ...:

  Additional arguments.

## Examples

``` r
sim <- boids_scenario("schooling_2d", n = 15, steps = 3, seed = 5)

if (requireNamespace("ggWebGL", quietly = TRUE)) {
  spec <- as_ggwebgl_spec(sim, vector_every = 10)
  names(spec)
}
#> [1] "package_version" "labels"          "webgl"           "layer_count"    
#> [5] "layers"          "render"         
```
