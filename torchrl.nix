{ lib, buildPythonPackage, fetchPypi, python }:

buildPythonPackage rec {
  pname = "torchrl";
  version = "0.3.1";
  format = "wheel";


  src = fetchPypi rec {
    inherit pname version format;
    sha256 = ""; # TODO
    dist = python;
    python = "py3";
    #abi = "none";
    #platform = "any";
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

