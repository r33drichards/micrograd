{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib;

buildPythonPackage rec {
  pname = "torchrl";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-hash-of-the-package"; # Replace with the actual sha256 hash
  };

  propagatedBuildInputs = [
    python.pkgs.torch
    # Add other dependencies if required
  ];

  meta = with lib; {
    description = "A reinforcement learning library for PyTorch";
    homepage = "https://github.com/pytorch/rl";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
