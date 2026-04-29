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
#>   frame time         id species          x            y z           vx
#> 1     0    0 boid-00001    boid -1.0317619  0.542366255 0 -0.155310145
#> 2     0    0 boid-00002    boid -0.5626548 -0.336099217 0 -0.553674972
#> 3     0    0 boid-00003    boid  0.3205548  0.782540118 0  0.281232730
#> 4     0    0 boid-00004    boid  1.7961143 -0.006672198 0 -0.011233402
#> 5     0    0 boid-00005    boid -1.3125995  0.631093674 0 -0.004047566
#> 6     0    0 boid-00006    boid  1.7529146  1.426527675 0  0.235959053
#>            vy vz     speed
#> 1  0.15495644  0 0.2193917
#> 2 -0.01403218  0 0.5538528
#> 3 -0.03894888  0 0.2839170
#> 4 -0.36768810  0 0.3678597
#> 5 -0.11953751  0 0.1196060
#> 6  0.10448539  0 0.2580579
```
