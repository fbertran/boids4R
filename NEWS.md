# boids4R 0.3.2

- Improved `as_ggwebgl_spec()` display defaults with high-contrast species and
  role palettes, emphasized current boids, faint recent trails, species-aware
  velocity vectors, and visible obstacle/predator rings.

# boids4R 0.3.1

- Updated `DESCRIPTION` for CRAN resubmission by removing the redundant
  trailing "for R" from the title and adding the formal Reynolds (1987)
  <doi:10.1145/37402.37406> method reference.
- Added the missing `\value{}` documentation for `as_ggwebgl_spec()` and
  described the `ggwebgl_spec` output structure.
- Improved `as_ggwebgl_spec()` display defaults with high-contrast species and
  role palettes, emphasized current boids, faint recent trails, species-aware
  velocity vectors, and visible obstacle/predator rings.
- Added alt text to the README logo image for pkgdown accessibility checks.

# boids4R 0.3.0

- Added a 3D-focused flock, herd, swarm, and school vignette with 2D overhead
  variants where they clarify the same collective-motion pattern.
- Added a swarm-art vignette showing how recorded frames can be turned into
  trail drawings, time-layered particle prints, negative-space obstacle
  compositions, and depth-coloured 3D projections.
- Added compact, deterministic examples to exported function documentation so
  CRAN checks exercise the user-facing API.
- Declared `ggWebGL (>= 0.4.0)` as the optional WebGL backend now that it is on
  CRAN, and guarded examples/tests against older adapter APIs.

# boids4R 0.2.0

- Added a scenario-gallery vignette covering built-in 2D and 3D swarm
  scenarios, renderer-neutral frame summaries, species-level diagnostics, base
  graphics snapshots, and optional `ggWebGL` handoff.
- Added a custom simulation workflow vignette showing explicit state, world,
  obstacle, predator, attractor, metric, parameter-sweep, and mixed-species 3D
  workflows.
- Updated the obstacle-corridor scenario so initial boid positions are sampled
  outside obstacle discs.
- Tuned custom workflow examples so the solid obstacle diagnostics show positive
  final obstacle clearance while preserving soft steering semantics.
- Declared `htmlwidgets` as a suggested package for manual WebGL export
  examples.
  
# boids4R 0.1.0
- Initial commit of the package.
