{ config, pkgs, ... }:
let
  flakeryDomain = builtins.readFile /metadata/flakery-domain;
  app = pkgs.stdenv.mkDerivation {
    name = "bopy";
    src = ./bo.py;
    buildInputs = with pkgs; with python3Packages; [
      python3
      numpy
      matplotlib
      scikit-learn
      ipykernel
      torch
      tqdm
      gymnasium
      torchvision
      tensorboard
      torch-tb-profiler
      opencv4
      tqdm
      # tensordict
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/bo.py
    '';
  };
  script = pkgs.writeShellScript "rebuild.sh" ''
    export DYLD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.python3Packages.pytorch ]}
    python3 -m venv /tmp/.venv
    # activate the virtual environment
    source /tmp/.venv/bin/activate
    pip install 'gymnasium[atari]'
    pip install 'gymnasium[accept-rom-license]'
    pip install gym-super-mario-bros==7.4.0
    pip install torchrl==0.3.0
    pip install tensordict==0.3.0
    python3 ${app}/bin/bo.py
  '';

in
{
  system.stateVersion = "23.05";
  # one shot systemd service to run the app
  # script should 


  services.tailscale = {
    enable = true;
    authKeyFile = "/tsauthkey";
    extraUpFlags = [ "--ssh" ];
  };

  users.users.flakery = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # password = "flakery"; # Set the password for the user.
  };
  # allow sudo without password for wheel
  security.sudo.wheelNeedsPassword = false;


  services.systemd.services.bopy = {
    inherit script;
    description = "bopy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.python3 ];
    serviceConfig = {
      Type = "oneshot";
      User = "flakery";
    };
  };
}
