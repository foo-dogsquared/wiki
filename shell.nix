{ pkgs ? import (fetchTarball "http://nixos.org/channels/nixos-21.05/nixexprs.tar.xz") {} }:

let
  python3WithPackages = pkgs.python3.withPackages(p:
    with pkgs.python3Packages; [
      pynvim
    ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake
    gnuplot
    graphviz
    lilypond
    nodejs-14_x
    octaveFull
    python3WithPackages
    racket
    R
    recoll
  ];
}
