{ lib, buildPythonPackage, fetchurl, python, ...}:

buildPythonPackage rec {  
  pname = "tensordict";
  version = "0.3.2";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/e2/bf/b3644078a1659d93cfed9022587f75b153b5558e4f292573c3df20994d5f/tensordict-0.3.2-cp311-cp311-manylinux1_x86_64.whl";
    sha256 = "sha256-x0ye9JNcviWpIpypiHeruNI0PvtdPHhURjL5Ss/3M8A="; # TODO: Add the sha256 hash for the wheel file
  };

  propagatedBuildInputs = [
    python.pkgs.torch
    # Add other dependencies if required
  ];

  # todo update me

  meta = with lib; {
    description = "A reinforcement learning library for PyTorch";
    homepage = "https://github.com/pytorch/rl";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

