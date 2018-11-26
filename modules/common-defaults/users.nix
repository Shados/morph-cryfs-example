{ config, lib, pkgs, ... }:

{
  deployment = {
    secrets = {
      # Provide the root password via a file containing the hashed unix
      # password. These can be generated with:
      # $ mkpasswd -m sha-512
      # In this case, the password is 'linux123' :)
      "root-password" = {
        # Relative to the deployment file
        source = "../secrets/decrypted/root.pass";
        destination = "/root/passwords/root.pass";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
      };
    };
  };
  users = {
    mutableUsers = false;
    users.root = {
      passwordFile = "/root/passwords/root.pass";
      openssh.authorizedKeys.keyFiles = [
        ../../pubkeys/morph-example.id_rsa.pub
      ];
    };
  };
}
