{
  description = "KOReader macOS mirror";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      overlay = import ./overlay.nix;

      forSystem = system:
        let pkgs = import nixpkgs { inherit system; };
        in overlay pkgs pkgs;
    in
    {
      overlays.default = overlay;

      packages.aarch64-darwin = forSystem "aarch64-darwin"
        // { default = self.packages.aarch64-darwin.koreader; };
      packages.x86_64-darwin = forSystem "x86_64-darwin"
        // { default = self.packages.x86_64-darwin.koreader; };
    };
}
