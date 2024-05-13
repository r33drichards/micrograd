{ config, pkgs, ... }:
let
  app = pkgs.stdenv.mkDerivation {
    name = "bopy";
    src = ./.;
    buildInputs = with pkgs; with python3Packages; [
      libstdcxx5
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
      tensordict
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp bo.py $out/bin/bo.py
    '';
  };
  script = ''
    export DYLD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.python3Packages.pytorch ]}
    python3 -m venv /tmp/.venv
    # activate the virtual environment
    source /tmp/.venv/bin/activate
    pip install 'gymnasium[atari]'
    pip install 'gymnasium[accept-rom-license]'
    pip install torchrl==0.3.0
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

  nix = {
    settings = {
      substituters = [
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.bopy = {
    inherit script;
    description = "bopy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.python3 ];
    serviceConfig = {
      Type = "oneshot";
      User = "flakery";
      Environment=''
        DYLD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.python3Packages.pytorch ]}
        LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.libstdcxx5 ]}
      '';
    };
  };
}
