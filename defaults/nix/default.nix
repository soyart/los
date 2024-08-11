{ inputs, ... }:

{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      # trusted-users = [ "root" "@wheel" ];
    };

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };

    optimise = {
      automatic = true;
      dates = [ "03:45" "17:45" ];
    };
  };

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };
}
