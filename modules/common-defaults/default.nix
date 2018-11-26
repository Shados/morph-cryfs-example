# This module defines default configuration shared between all managed hosts
{ config, lib, pkgs, ... }:
with lib;
let
  scriptPathFor = scriptName: scriptContents: toString (pkgs.writeScript scriptName scriptContents);
in
{
  system.stateVersion = mkDefault "18.09";

  imports = [
    ./nix.nix
    ./users.nix
  ];

  time.timeZone = "Australia/Melbourne";

  environment.systemPackages = with pkgs; [
    tmux rsync tree
    rxvt_unicode.terminfo
  ];

  programs.bash.enableCompletion = true;

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      permitRootLogin = "without-password";
    };
  };

  deployment = {
    # Some morph deployment health checks that are generic enough to run on all hosts
    healthChecks.cmd = [
      { cmd = [
          (scriptPathFor "systemd-job-healthcheck" ''
            test $(systemctl status --no-legend --no-pager | egrep -c "\s*Jobs: 0 queued\s*") -eq 1
            test $(systemctl status --no-legend --no-pager | egrep -c "^\s*Failed: 0 units\s*") -eq 1
          '')
        ];
        description = "Check systemd for failed or still-queued/waiting jobs.";
      }
    ];
  };
}
