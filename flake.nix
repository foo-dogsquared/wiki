{
  description = "The flake for this project.";
  outputs = inputs@{ self, nixpkgs, ... }: {
    devShell.x86_64-linux = import ./shell.nix { pkgs = import nixpkgs { system = "x86_64-linux"; }; };
  };
}
