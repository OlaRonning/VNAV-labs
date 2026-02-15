{
  description = "VNAV Labs — ROS 2 Humble development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-ros-overlay = {
      url = "github:lopsided98/nix-ros-overlay/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-ros-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-ros-overlay.overlays.default ];
      };
      ros = pkgs.rosPackages.humble;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "ros-humble-vnav";

        packages = with pkgs; with ros; [
          # ── Build tools ────────────────────────────────────────────────
          ros-core
          colcon
          ament-cmake
          ament-cmake-auto
          rosidl-default-generators
          rosidl-default-runtime

          # ── Core ROS 2 client library ──────────────────────────────────
          rclcpp
          rclpy

          # ── Standard message types ─────────────────────────────────────
          std-msgs
          geometry-msgs
          nav-msgs
          trajectory-msgs
          visualization-msgs
          sensor-msgs

          # ── TF2 (transform library) ────────────────────────────────────
          tf2
          tf2-ros
          tf2-py
          tf2-msgs
          tf2-geometry-msgs
          tf2-sensor-msgs
          tf2-eigen

          # ── Launch ─────────────────────────────────────────────────────
          launch
          launch-ros

          # ── Vision / image processing ──────────────────────────────────
          image-transport
          cv-bridge
          opencv                  # labs 5, 6

          # ── Linear algebra ─────────────────────────────────────────────
          eigen                   # Eigen3 — labs 3, 4
          eigen3-cmake-module     # FindEigen3 cmake helper

          # ── SLAM / optimisation ────────────────────────────────────────
          gtsam                   # labs 7, 8
          nlopt                   # lab 4 trajectory generation

          # ── Multi-view geometry ────────────────────────────────────────
          # opengv                # lab 6 — not yet in nix-ros-overlay

          # ── Logging / diagnostics ──────────────────────────────────────
          pkgs.glog               # labs 4–8 (system package, not ROS)
          pkgs.gflags             # lab 4

          # ── Misc system libs ───────────────────────────────────────────
          pkgs.yaml-cpp           # lab 4
          pkgs.boost              # lab 9 / general

          # ── Python deps (lab 3 tesse-interface) ───────────────────────
          pkgs.python3Packages.numpy
          pkgs.python3Packages.pillow
          pkgs.python3Packages.defusedxml

          # ── NOT available in nix-ros-overlay — build from source ───────
          # mav-msgs
          # mav-planning-msgs
          # mav-trajectory-generation
          # mav-visualization
          # ultralytics-ros
        ];

        shellHook = ''
          export ROS_HOSTNAME=localhost
          export ROS_MASTER_URI=http://localhost:11311/
        '';
      };
    };
}
