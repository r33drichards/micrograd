{ lib, buildPythonPackage, fetchPypi, python }:

buildPythonPackage rec {
  pname = "torchrl";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = ""; # Replace with the actual sha256 hash
        extension = ".whl";

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
