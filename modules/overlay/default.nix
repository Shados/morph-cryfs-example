self: super: {
  morph = with builtins; let
    pin = fromJSON (readFile ../../pins/morph.json);
    checkout = super.fetchgit { inherit (pin) url rev sha256; };
  in super.callPackage "${checkout}/nix-packaging/default.nix" { version = pin.rev; };
  # Use a slightly newer version of cryfs than is in 18.09, if the current pkgs
  # does not already have a newer version
  cryfs = let
    cryfs_10_m3 = super.cryfs.overrideAttrs(oldAttrs: rec { # {{{
      name = "cryfs-${version}";
      version = "0.10-m3";

      src = super.fetchFromGitHub {
        owner  = "cryfs";
        repo   = "cryfs";
        rev    = "${version}";
        sha256 = "0rark35j6dizsz9cz73yswa6nk9lbbb3r78x5z2g4xp6km7inlbv";
      };

      # A directory name changed in the vendored scrypt copy, resulting in us
      # needing to override prePatch with a slightly altered copy
      prePatch = ''
        patchShebangs src

        substituteInPlace vendor/scrypt/CMakeLists.txt \
          --replace /usr/bin/ ""

        # scrypt in nixpkgs only produces a binary so we lift the patching from that so allow
        # building the vendored version. This is very much NOT DRY.
        # The proper solution is to have scrypt generate a dev output with the required files and just symlink
        # into vendor/scrypt
        for f in Makefile.in autotools/Makefile.am libcperciva/cpusupport/Build/cpusupport.sh ; do
          substituteInPlace vendor/scrypt/scrypt-*/scrypt/$f --replace "command -p " ""
        done

        # cryfs is vendoring an old version of spdlog
        rm -rf vendor/spdlog/spdlog
        ln -s ${super.spdlog} vendor/spdlog/spdlog
      '';
    }); # }}}
  in with super.lib; if versionOlder (getVersion super.cryfs) "0.10"
    then cryfs_10_m3
    else super.cryfs;
}
