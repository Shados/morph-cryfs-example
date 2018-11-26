{ version ? "18.09"
, pkgs ? import ./modules/nixpkgs-pinned.nix { inherit version; }
}:
let
  shell = import ./shell.nix { inherit version pkgs; };
in (shell.overrideAttrs(oldAttrs: {
  shellHook = oldAttrs.shellHook + ''
    trap cleanup EXIT

    function cleanup() {
      status=$?
      fusermount -u "$SECRETS_DIR/decrypted"
      exit $status
    }

    SECRETS_DIR=$(realpath secrets)

    cryfs "$SECRETS_DIR/encrypted" "$SECRETS_DIR/decrypted"
  '';
}))
