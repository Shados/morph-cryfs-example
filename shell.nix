{ version ? "18.09"
, pkgs ? import ./modules/nixpkgs-pinned.nix { inherit version; }
}:

with pkgs;
stdenv.mkDerivation {
  name = "morph-cryfs-env";
  buildInputs = [
    bashInteractive
    curl git jq nix-prefetch-git openssh rsync morph
    cryfs utillinux
  ];

  shellHook = ''
    export SSH_USER=root
    export SSH_IDENTITY_FILE=./secrets/decrypted/morph-example.id_rsa
    source <(morph --completion-script-bash)
  '';
}
