args@{ version, ... }:
with builtins;
let
  pin = fromJSON (readFile (../pins/nixpkgs- + version + ".json"));

  # Prepend the default overlay to args.overlays
  overlays = [ (import ./overlay) ] ++ (args . overlays or []);
  nixpkgsArgs = (removeAttrs args ["version"]) // { overlays = overlays; };

  pkgs = import (fetchTarball { inherit (pin) url sha256; }) nixpkgsArgs;

in pkgs
