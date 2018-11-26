{ config, lib, pkgs, ... }:
with lib;
{
  nix = {
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "03:45";
      options = mkDefault "--delete-older-than 14d";
    };
  };

  environment.variables = {
    NIX_PATH = lib.mkForce "nixpkgs=${pkgs.path}";
  };
}
