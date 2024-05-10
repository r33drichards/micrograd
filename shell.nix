{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; with python3Packages; [
    pkgs.python3
    pkgs.python3Packages.numpy
    matplotlib
    scikit-learn
    ipykernel
    torch
    tqdm
    torchvision

  ];
}