{ pkgs ? import (fetchTarball "http://nixos.org/channels/nixos-20.09/nixexprs.tar.xz") {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake
    gnuplot
    graphviz
    lilypond
    octaveFull
    python3
    racket
    R
    recoll
  ];
}
