test_that("constructors produce renderer-neutral state", {
  params <- boids_params("3d")
  world <- boids_world("3d")
  state <- boids_state(12, "3d", seed = 1)
  
  expect_s3_class(params, "boids_params")
  expect_s3_class(world, "boids_world")
  expect_s3_class(state, "boids_state")
  forbidden <- c("scene", "camera", "viewport", "shader", "widget", "layers")
  expect_false(any(forbidden %in% names(params)))
  expect_false(any(forbidden %in% names(world)))
  expect_false(any(forbidden %in% names(state)))
})

test_that("simulation returns expected columns and finite bounded values", {
  state <- boids_state(24, "2d", seed = 2)
  world <- boids_world("2d", boundary = "reflect")
  sim <- simulate_boids(state, world, boids_params("2d", max_speed = 0.8), steps = 8, seed = 3)
  frames <- as.data.frame(sim)
  
  expect_s3_class(sim, "boids_simulation")
  expect_true(all(c("frame", "time", "id", "species", "x", "y", "z", "vx", "vy", "vz", "speed") %in% names(frames)))
  expect_true(all(is.finite(frames$x)))
  expect_true(all(abs(frames$z) < 1e-12))
  expect_lte(max(frames$speed), 0.8 + 1e-8)
})

test_that("simulation is reproducible with a fixed seed", {
  state <- boids_state(20, "2d", seed = 4)
  sim1 <- simulate_boids(state, steps = 6, seed = 99)
  sim2 <- simulate_boids(state, steps = 6, seed = 99)
  expect_equal(as.data.frame(sim1), as.data.frame(sim2), tolerance = 1e-12)
})

test_that("seeded state construction does not modify the global RNG state", {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv, inherits = FALSE) else NULL
  
  state1 <- boids_state(8, "2d", seed = 123)
  state2 <- boids_state(8, "2d", seed = 123)
  expect_equal(state1, state2)
  
  if (had_seed) {
    expect_identical(get(".Random.seed", envir = .GlobalEnv, inherits = FALSE), old_seed)
  } else {
    expect_false(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
  }
})

test_that("seeded simulation noise is reproducible without R-level set.seed", {
  state <- boids_state(12, "2d", seed = 11)
  params <- boids_params("2d", noise = 0.01)
  sim1 <- simulate_boids(state, params = params, steps = 5, seed = 101)
  sim2 <- simulate_boids(state, params = params, steps = 5, seed = 101)
  expect_equal(as.data.frame(sim1), as.data.frame(sim2), tolerance = 1e-12)
})

test_that("grid and naive engines agree when all boids share one cell", {
  bounds <- matrix(c(-0.2, -0.2, 0.2, 0.2), ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))
  state <- boids_state(10, "2d", bounds = bounds, seed = 5)
  world <- boids_world("2d", bounds = bounds, boundary = "reflect")
  params <- boids_params("2d", cohesion_radius = 1, alignment_radius = 1, separation_radius = 1, noise = 0)
  grid <- simulate_boids(state, world, params, steps = 4, engine = "rcpp_grid", seed = 7)
  naive <- simulate_boids(state, world, params, steps = 4, engine = "rcpp_naive", seed = 7)
  expect_equal(as.data.frame(grid), as.data.frame(naive), tolerance = 1e-10)
})

test_that("named scenarios cover 2d and 3d full-lab cases", {
  names <- c("murmuration_3d", "predator_avoidance_2d", "obstacle_corridor_2d", "schooling_2d", "mixed_species_3d")
  sims <- lapply(names, boids_scenario, n = 18, steps = 4, seed = 8)
  expect_equal(vapply(sims, function(x) x$scenario, character(1)), names)
  expect_true(any(vapply(sims, function(x) identical(x$dimension, "3d"), logical(1))))
  expect_true(any(vapply(sims, function(x) identical(x$dimension, "2d"), logical(1))))
})

test_that("obstacle corridor scenario does not initialize boids inside obstacles", {
  sim <- boids_scenario("obstacle_corridor_2d", n = 80, steps = 1, seed = 10)
  initial <- as.data.frame(sim)
  initial <- initial[initial$frame == 0L, , drop = FALSE]
  obstacles <- sim$world$obstacles
  
  for (i in seq_len(nrow(obstacles))) {
    distance <- sqrt(
      (initial$x - obstacles$x[i])^2 +
        (initial$y - obstacles$y[i])^2 +
        (initial$z - obstacles$z[i])^2
    )
    expect_true(all(distance >= obstacles$radius[i]))
  }
})

test_that("predator and obstacle forces move nearby boids away", {
  state <- boids_state(
    1, "2d",
    positions = matrix(c(0.05, 0), ncol = 2),
    velocities = matrix(c(0, 0), ncol = 2)
  )
  predator_world <- boids_world("2d", boundary = "open", predators = data.frame(x = 0, y = 0, radius = 1, strength = 1))
  obstacle_world <- boids_world("2d", boundary = "open", obstacles = data.frame(x = 0, y = 0, radius = 1))
  params <- boids_params("2d", cohesion_weight = 0, alignment_weight = 0, separation_weight = 0, noise = 0)
  pred <- tail(as.data.frame(simulate_boids(state, predator_world, params, steps = 1)), 1)
  obs <- tail(as.data.frame(simulate_boids(state, obstacle_world, params, steps = 1)), 1)
  expect_gt(pred$vx, 0)
  expect_gt(obs$vx, 0)
})

test_that("optional ggWebGL adapter emits timeline and 3d view metadata", {
  skip_if_not_installed("ggWebGL")
  skip_if(
    utils::packageVersion("ggWebGL") < "0.4.0",
    "ggWebGL >= 0.4.0 is required for the boids4R adapter"
  )
  
  sim <- boids_scenario("murmuration_3d", n = 20, steps = 4, seed = 9)
  spec <- as_ggwebgl_spec(sim, vector_every = 4)
  expect_equal(spec$render$timeline$filter, "exact")
  expect_equal(spec$render$dimension, "3d")
  expect_true("vectors" %in% spec$render$primitives)
})
