# boids4R: Reynolds-style boids and swarm simulation for R

`boids4R` owns simulation state and frame generation. Visualization
packages can consume exported frames or optional adapters, but core
`boids4R` objects do not contain renderer-specific camera, scene,
shader, or widget fields.

## See also

Useful links:

- <https://fbertran.github.io/boids4R/>

- <https://github.com/fbertran/boids4R>

- Report bugs at <https://github.com/fbertran/boids4R/issues>

## Author

**Maintainer**: Frederic Bertrand <frederic.bertrand@lecnam.net>
([ORCID](https://orcid.org/0000-0002-0837-8281))

## Examples

``` r
sim <- boids_scenario("schooling_2d", n = 12, steps = 3, seed = 1)
head(as.data.frame(sim))
#>   frame time         id species          x           y z           vx
#> 1     0    0 boid-00001    boid -2.1999656  0.95979950 0 -0.024700034
#> 2     0    0 boid-00002    boid -1.6212337 -1.34974088 0 -0.142371844
#> 3     0    0 boid-00003    boid  1.1246634 -1.29496126 0  0.005966604
#> 4     0    0 boid-00004    boid -0.1819394  0.08613056 0 -0.282932210
#> 5     0    0 boid-00005    boid  0.1441758  0.49633321 0 -0.316795802
#> 6     0    0 boid-00006    boid -1.2365796 -1.42767526 0 -0.444897707
#>            vy vz      speed
#> 1 -0.01541146  0 0.02911365
#> 2  0.10727189  0 0.17826105
#> 3 -0.16972742  0 0.16983226
#> 4  0.07166737  0 0.29186786
#> 5  0.04230388  0 0.31960788
#> 6 -0.40671955  0 0.60278915
```
