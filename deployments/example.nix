let
  pkgs = import ../modules/nixpkgs-pinned.nix { version = "18.09"; };
in
{
  network = {
    inherit pkgs;
    description = "An example deployment using cryfs to decrypt secrets at deploy-time";
  };

  "192.168.2.104" = { config, lib, pkgs, ...}: {
    imports = [
      ../modules/common-defaults/default.nix
    ];
    networking.hostName = "cryfs-example";
    networking.defaultGateway = "192.168.2.254";
    networking.interfaces.ens32.ipv4.addresses = [
      { address = "192.168.2.104"; prefixLength = 24; }
    ];

    # Hardware stuff
    boot.loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos-root";
      fsType = "ext4";
    };
    boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "floppy" "sd_mod" "sr_mod" ];
    nix.maxJobs = lib.mkDefault 1;
  };
}

