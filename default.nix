# default.nix — non-flake entry point
#
# Usage:
#   nix-build -A koreader
#   nix-shell -p '(import ./. {}).koreader'
#
# As a nixpkgs overlay:
#   { nixpkgs.overlays = [ (import ./overlay.nix) ]; }

{ pkgs ? import <nixpkgs> { } }:

(import ./overlay.nix) pkgs pkgs
