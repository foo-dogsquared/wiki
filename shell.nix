{ pkgs ? import <nixpkgs> { } }:

let
  python3WithPackages = pkgs.python3.withPackages(p:
    with pkgs.python3Packages; [
      pynvim
      jupyter
      black
    ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    flow
    gcc
    gnumake
    gnuplot
    graphviz
    lilypond
    nodejs-16_x
    octaveFull
    python3WithPackages
    racket
    R
    recoll
  ];
}
