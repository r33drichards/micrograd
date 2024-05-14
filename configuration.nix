{ config, pkgs, ... }:
let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
      numpy
      matplotlib
      scikit-learn
      ipykernel
      tqdm
      gymnasium
      torchvision
      tensorboard
      torch-tb-profiler
      opencv4
      tqdm
      # tensordict
      torchrl
      torch
  ]);
  app = pkgs.stdenv.mkDerivation {
    name = "bopy";
    src = ./.;
    buildInputs = with pkgs; with python3Packages; [
      libstdcxx5
      pythonEnv
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp bo.py $out/bin/bo.py
    '';
  };
  torchrl = pkgs.callPackage ./torchrl.nix {
    # { lib, buildPythonPackage, fetchPypi, python }:
    lib = pkgs.lib;
    buildPythonPackage = pkgs.python3Packages.buildPythonPackage;
    python = pkgs.python3;
    fetchurl = pkgs.fetchurl;

   };
  script = ''
    rm -rf /tmp/.venv
    ${pythonEnv}/bin/python3 -m venv /tmp/.venv
    # activate the virtual environment
    source /tmp/.venv/bin/activate
    pip install 'gymnasium[atari]'
    pip install 'gymnasium[accept-rom-license]'
    pip install tensordict==0.3.0
    python ${app}/bin/bo.py
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
    packages = with pkgs; [
      app
      pythonEnv
    ];
  };
  # allow sudo without password for wheel
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."flakery".openssh.authorizedKeys.keys = [
    # replace with your ssh key 
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/e5M8zDNH5DUmqCGKM0OhHKU5iHFum3IUekq8Fqvegur7G2fhsmQnp09Mjc5pEw2AbfTYz11WMHsvC5WQdRWSS2YyZHYsPb9zIsVBNcss+H5x63ItsDjmbrS6m/9r7mRBOiN265+Mszc5lchFtRFetpi9f+EBis9r8atyPlsz86IoS2UxSSWonBARU4uwy2+TT7+mYg3cQf7kp1Y1sTqshXmcHUC5UVSRk3Ny9IbIMhk19fOxr3y8gaXoT5lB0NSLO8XFNbNT6rjZXH1kpiPJh3xLlWBPQtbcLrpm8oSS51zH7+zAGb7mauDHu2RcfBgq6m1clZ6vff65oVuHOI7"
  ];



  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.bopy = {
    inherit script;
    description = "bopy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "flakery";
      Environment=''
        PYTHONHOME=${pythonEnv}
        DYLD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.python3Packages.pytorch ]}
        LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.libstdcxx5 ]}
      '';
    };
  };
}
