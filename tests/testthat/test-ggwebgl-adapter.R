skip_ggwebgl_adapter <- function() {
  skip_if_not_installed("ggWebGL")
  skip_if(
    utils::packageVersion("ggWebGL") < "0.4.0",
    "ggWebGL >= 0.4.0 is required for the boids4R adapter"
  )
}

layer_rgba <- function(layer) {
  matrix(layer$rgba, ncol = 4, byrow = TRUE)
}

layers_of_type <- function(spec, type) {
  Filter(function(layer) identical(layer$type, type), spec$render$layers)
}

animated_point_layers <- function(spec) {
  Filter(function(layer) "frame" %in% names(layer), layers_of_type(spec, "points"))
}

vector_layer <- function(spec) {
  layers <- layers_of_type(spec, "vectors")
  if (!length(layers)) return(NULL)
  layers[[1L]]
}

test_that("default display palette is high contrast and overrideable", {
  skip_ggwebgl_adapter()

  keys <- c("species_1", "species_2", "prey", "predator", "obstacle", "vector")
  pal <- boids4R:::boids_default_palette
  expect_true(all(keys %in% names(pal)))
  expect_equal(length(unique(unname(pal[keys]))), length(keys))

  sim <- boids_scenario("mixed_species_3d", n = 6, steps = 2, seed = 21)
  spec <- as_ggwebgl_spec(
    sim,
    trail = "none",
    vector_mode = "none",
    role_palette = c(swift = "#000000", tern = "#FFFFFF", kite = "#00FF00")
  )
  rgb <- unique(round(layer_rgba(animated_point_layers(spec)[[1L]])[, 1:3], 4))

  expect_true(any(rowSums(abs(sweep(rgb, 2, c(0, 0, 0)))) < 1e-8))
  expect_true(any(rowSums(abs(sweep(rgb, 2, c(1, 1, 1)))) < 1e-8))
  expect_true(any(rowSums(abs(sweep(rgb, 2, c(0, 1, 0)))) < 1e-8))
})

test_that("current boids are emphasized separately from optional trails", {
  skip_ggwebgl_adapter()

  sim <- boids_scenario("schooling_2d", n = 5, steps = 6, seed = 22)
  spec <- as_ggwebgl_spec(
    sim,
    boid_size = 6,
    current_alpha = 0.8,
    trail_alpha = 0.1,
    vector_mode = "none"
  )
  points <- animated_point_layers(spec)
  expect_equal(length(points), 2)

  trail <- points[[1L]]
  current <- points[[2L]]
  expect_gt(current$rows, 0)
  expect_true(all(current$size == 6))
  expect_equal(unique(round(layer_rgba(current)[, 4], 3)), 0.8)
  expect_lt(max(layer_rgba(trail)[, 4]), min(layer_rgba(current)[, 4]))

  no_trail <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "none")
  expect_equal(length(animated_point_layers(no_trail)), 1)
})

test_that("vector modes control row counts without changing simulation frames", {
  skip_ggwebgl_adapter()

  sim <- boids_scenario("schooling_2d", n = 5, steps = 4, seed = 23)
  frames <- as.data.frame(sim)

  current <- vector_layer(as_ggwebgl_spec(sim, trail = "none", vector_mode = "current"))
  expect_equal(current$rows, nrow(frames))
  expect_true(all(table(current$frame) == length(unique(frames$id))))

  sampled <- vector_layer(as_ggwebgl_spec(sim, trail = "none", vector_mode = "sampled", vector_every = 3))
  expect_equal(sampled$rows, ceiling(nrow(frames) / 3))

  no_vectors <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "none")
  expect_null(vector_layer(no_vectors))
})

test_that("vector colours can follow species, roles, or a fixed colour", {
  skip_ggwebgl_adapter()

  sim <- boids_scenario("mixed_species_3d", n = 6, steps = 2, seed = 24)

  species_spec <- as_ggwebgl_spec(sim, trail = "none", vector_colour_mode = "species")
  species_rgb <- unique(round(layer_rgba(vector_layer(species_spec))[, 1:3], 4))
  expect_gt(nrow(species_rgb), 1)

  fixed_spec <- as_ggwebgl_spec(
    sim,
    trail = "none",
    vector_colour_mode = "fixed",
    vector_colour = "#000000"
  )
  fixed_rgb <- unique(round(layer_rgba(vector_layer(fixed_spec))[, 1:3], 4))
  expect_equal(nrow(fixed_rgb), 1)
  expect_equal(unname(fixed_rgb[1, ]), c(0, 0, 0))

  ids <- unique(sim$frames$id)
  sim$frames$role <- ifelse(sim$frames$id %in% ids[seq_len(length(ids) / 2)], "prey", "predator")
  role_spec <- as_ggwebgl_spec(
    sim,
    trail = "none",
    vector_colour_mode = "role",
    role_palette = c(prey = "#000000", predator = "#FFFFFF")
  )
  role_rgb <- unique(round(layer_rgba(vector_layer(role_spec))[, 1:3], 4))
  expect_true(any(rowSums(abs(sweep(role_rgb, 2, c(0, 0, 0)))) < 1e-8))
  expect_true(any(rowSums(abs(sweep(role_rgb, 2, c(1, 1, 1)))) < 1e-8))
})

test_that("obstacle rings are visible and can be omitted", {
  skip_ggwebgl_adapter()

  sim <- boids_scenario("obstacle_corridor_2d", n = 8, steps = 2, seed = 25)
  ring_spec <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "none", obstacle_mode = "ring")
  line_layers <- layers_of_type(ring_spec, "lines")
  expect_equal(length(line_layers), 1)
  expect_equal(line_layers[[1L]]$path_count, nrow(sim$world$obstacles))

  none_spec <- as_ggwebgl_spec(sim, trail = "none", vector_mode = "none", obstacle_mode = "none")
  expect_equal(length(layers_of_type(none_spec, "lines")), 0)
})
