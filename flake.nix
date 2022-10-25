{
  description = "The flake for this digital notebook.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    foo-dogsquared-nixos-config.url = "github:foo-dogsquared/nixos-config";
    foo-dogsquared-nixos-config.inputs.nixpkgs.follows = "nixpkgs";
    foo-dogsquared-nixos-config.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, ... }: let
    overlays = [
      inputs.foo-dogsquared-nixos-config.overlays.default
    ];
    defaultSystem = inputs.flake-utils.lib.system.x86_64-linux;
    systems = with inputs.flake-utils.lib.system; [ defaultSystem ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system overlays; };
    in
      { default = import ./shell.nix { inherit pkgs; }; });
  };
}
