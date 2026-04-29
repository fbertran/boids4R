#include <Rcpp.h>
#include <algorithm>
#include <cmath>
#include <string>
#include <unordered_map>
#include <vector>
using namespace Rcpp;

struct Vec3 {
  double x, y, z;
};

static double norm3(const Vec3& v) {
  return std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

static Vec3 add3(const Vec3& a, const Vec3& b) { return {a.x + b.x, a.y + b.y, a.z + b.z}; }
static Vec3 sub3(const Vec3& a, const Vec3& b) { return {a.x - b.x, a.y - b.y, a.z - b.z}; }
static Vec3 mul3(const Vec3& a, double s) { return {a.x * s, a.y * s, a.z * s}; }

static Vec3 limit3(Vec3 v, double max_norm) {
  double n = norm3(v);
  if (n > max_norm && n > 1e-12) return mul3(v, max_norm / n);
  return v;
}

static Vec3 normalise3(Vec3 v) {
  double n = norm3(v);
  if (n <= 1e-12) return {0, 0, 0};
  return mul3(v, 1.0 / n);
}

static double param(NumericVector params, const char* name, double fallback) {
  CharacterVector nms = params.names();
  for (int i = 0; i < nms.size(); ++i) {
    if (std::string(CHAR(nms[i])) == name) return params[i];
  }
  return fallback;
}

static std::string cell_key(const Vec3& p, const NumericMatrix& bounds, double cell, int dimension) {
  int ix = static_cast<int>(std::floor((p.x - bounds(0, 0)) / cell));
  int iy = static_cast<int>(std::floor((p.y - bounds(1, 0)) / cell));
  int iz = dimension == 3 ? static_cast<int>(std::floor((p.z - bounds(2, 0)) / cell)) : 0;
  return std::to_string(ix) + ":" + std::to_string(iy) + ":" + std::to_string(iz);
}

static void apply_boundary(Vec3& p, Vec3& v, const NumericMatrix& bounds, const std::string& boundary, int dimension) {
  int dims = dimension == 3 ? 3 : 2;
  double* coords[3] = {&p.x, &p.y, &p.z};
  double* vel[3] = {&v.x, &v.y, &v.z};
  for (int d = 0; d < dims; ++d) {
    double lo = bounds(d, 0), hi = bounds(d, 1), width = hi - lo;
    if (boundary == "wrap") {
      while (*coords[d] < lo) *coords[d] += width;
      while (*coords[d] > hi) *coords[d] -= width;
    } else if (boundary == "reflect") {
      if (*coords[d] < lo) { *coords[d] = lo + (lo - *coords[d]); *vel[d] *= -1; }
      if (*coords[d] > hi) { *coords[d] = hi - (*coords[d] - hi); *vel[d] *= -1; }
    }
  }
  if (dimension == 2) { p.z = 0; v.z = 0; }
}

// [[Rcpp::export]]
DataFrame boids_simulate_cpp(NumericVector x,
                             NumericVector y,
                             NumericVector z,
                             NumericVector vx,
                             NumericVector vy,
                             NumericVector vz,
                             CharacterVector ids,
                             CharacterVector species,
                             NumericMatrix bounds,
                             std::string boundary,
                             NumericMatrix obstacles,
                             NumericMatrix attractors,
                             NumericMatrix predators,
                             NumericVector params,
                             int steps,
                             double dt,
                             int record_every,
                             int dimension,
                             bool use_grid) {
  int n = x.size();
  std::vector<Vec3> pos(n), vel(n);
  for (int i = 0; i < n; ++i) {
    pos[i] = {x[i], y[i], dimension == 3 ? z[i] : 0.0};
    vel[i] = {vx[i], vy[i], dimension == 3 ? vz[i] : 0.0};
  }

  double sep_w = param(params, "separation_weight", 1.45);
  double ali_w = param(params, "alignment_weight", 0.85);
  double coh_w = param(params, "cohesion_weight", 0.72);
  double goal_w = param(params, "goal_weight", 0.08);
  double obs_w = param(params, "obstacle_weight", 1.6);
  double pred_w = param(params, "predator_weight", 2.2);
  double sep_r = param(params, "separation_radius", 0.18);
  double ali_r = param(params, "alignment_radius", 0.46);
  double coh_r = param(params, "cohesion_radius", 0.64);
  double obs_r = param(params, "obstacle_radius", 0.38);
  double pred_r = param(params, "predator_radius", 0.72);
  double max_speed = param(params, "max_speed", 1.25);
  double max_force = param(params, "max_force", 0.075);
  double noise = param(params, "noise", 0.003);
  double cell = std::max({sep_r, ali_r, coh_r, pred_r, 1e-6});

  std::vector<int> frame_out;
  std::vector<double> time_out, x_out, y_out, z_out, vx_out, vy_out, vz_out, speed_out;
  std::vector<std::string> id_out, species_out;
  int reserve = (steps / record_every + 1) * n;
  frame_out.reserve(reserve); time_out.reserve(reserve); x_out.reserve(reserve); y_out.reserve(reserve); z_out.reserve(reserve);
  vx_out.reserve(reserve); vy_out.reserve(reserve); vz_out.reserve(reserve); speed_out.reserve(reserve);
  id_out.reserve(reserve); species_out.reserve(reserve);

  auto record = [&](int frame) {
    for (int i = 0; i < n; ++i) {
      frame_out.push_back(frame);
      time_out.push_back(frame * dt);
      id_out.push_back(as<std::string>(ids[i]));
      species_out.push_back(as<std::string>(species[i]));
      x_out.push_back(pos[i].x); y_out.push_back(pos[i].y); z_out.push_back(pos[i].z);
      vx_out.push_back(vel[i].x); vy_out.push_back(vel[i].y); vz_out.push_back(vel[i].z);
      speed_out.push_back(norm3(vel[i]));
    }
  };

  record(0);
  for (int step = 1; step <= steps; ++step) {
    std::unordered_map<std::string, std::vector<int> > grid;
    if (use_grid) {
      for (int i = 0; i < n; ++i) grid[cell_key(pos[i], bounds, cell, dimension)].push_back(i);
    }
    std::vector<Vec3> next_vel(n);
    for (int i = 0; i < n; ++i) {
      Vec3 sep = {0, 0, 0}, ali = {0, 0, 0}, coh = {0, 0, 0};
      int sep_c = 0, ali_c = 0, coh_c = 0;
      std::vector<int> candidates;
      if (use_grid) {
        int ix0 = static_cast<int>(std::floor((pos[i].x - bounds(0, 0)) / cell));
        int iy0 = static_cast<int>(std::floor((pos[i].y - bounds(1, 0)) / cell));
        int iz0 = dimension == 3 ? static_cast<int>(std::floor((pos[i].z - bounds(2, 0)) / cell)) : 0;
        for (int dx = -1; dx <= 1; ++dx) for (int dy = -1; dy <= 1; ++dy) for (int dz = (dimension == 3 ? -1 : 0); dz <= (dimension == 3 ? 1 : 0); ++dz) {
          std::string key = std::to_string(ix0 + dx) + ":" + std::to_string(iy0 + dy) + ":" + std::to_string(iz0 + dz);
          if (grid.find(key) != grid.end()) candidates.insert(candidates.end(), grid[key].begin(), grid[key].end());
        }
      } else {
        candidates.resize(n);
        for (int j = 0; j < n; ++j) candidates[j] = j;
      }
      for (int j : candidates) {
        if (j == i) continue;
        Vec3 d = sub3(pos[i], pos[j]);
        double dist = norm3(d);
        if (dist < 1e-12) continue;
        if (dist < sep_r) { sep = add3(sep, mul3(normalise3(d), 1.0 / dist)); sep_c++; }
        if (dist < ali_r) { ali = add3(ali, vel[j]); ali_c++; }
        if (dist < coh_r) { coh = add3(coh, pos[j]); coh_c++; }
      }
      if (sep_c) sep = mul3(normalise3(sep), sep_w);
      if (ali_c) ali = mul3(normalise3(mul3(ali, 1.0 / ali_c)), ali_w);
      if (coh_c) coh = mul3(normalise3(sub3(mul3(coh, 1.0 / coh_c), pos[i])), coh_w);

      Vec3 force = add3(add3(sep, ali), coh);
      for (int k = 0; k < attractors.nrow(); ++k) {
        Vec3 a = {attractors(k, 0), attractors(k, 1), dimension == 3 ? attractors(k, 2) : 0.0};
        force = add3(force, mul3(normalise3(sub3(a, pos[i])), goal_w * attractors(k, 3)));
      }
      for (int k = 0; k < obstacles.nrow(); ++k) {
        Vec3 o = {obstacles(k, 0), obstacles(k, 1), dimension == 3 ? obstacles(k, 2) : 0.0};
        double r = obstacles(k, 3) > 0 ? obstacles(k, 3) : obs_r;
        Vec3 d = sub3(pos[i], o); double dist = norm3(d);
        if (dist < r + obs_r && dist > 1e-12) force = add3(force, mul3(normalise3(d), obs_w / std::max(dist, 0.05)));
      }
      for (int k = 0; k < predators.nrow(); ++k) {
        Vec3 p = {predators(k, 0), predators(k, 1), dimension == 3 ? predators(k, 2) : 0.0};
        double r = predators(k, 3) > 0 ? predators(k, 3) : pred_r;
        double strength = predators.ncol() > 4 ? predators(k, 4) : 1.0;
        Vec3 d = sub3(pos[i], p); double dist = norm3(d);
        if (dist < r + pred_r && dist > 1e-12) force = add3(force, mul3(normalise3(d), pred_w * strength / std::max(dist, 0.05)));
      }
      if (noise > 0) {
        force = add3(force, {R::rnorm(0, noise), R::rnorm(0, noise), dimension == 3 ? R::rnorm(0, noise) : 0.0});
      }
      force = limit3(force, max_force);
      next_vel[i] = limit3(add3(vel[i], force), max_speed);
    }
    for (int i = 0; i < n; ++i) {
      vel[i] = next_vel[i];
      pos[i] = add3(pos[i], mul3(vel[i], dt));
      apply_boundary(pos[i], vel[i], bounds, boundary, dimension);
    }
    if (step % record_every == 0) record(step);
  }

  return DataFrame::create(
    _["frame"] = frame_out,
    _["time"] = time_out,
    _["id"] = id_out,
    _["species"] = species_out,
    _["x"] = x_out,
    _["y"] = y_out,
    _["z"] = z_out,
    _["vx"] = vx_out,
    _["vy"] = vy_out,
    _["vz"] = vz_out,
    _["speed"] = speed_out
  );
}
