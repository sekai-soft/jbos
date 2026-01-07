{ config, lib, pkgs, ... }:

let
  vars = import ./vars.nix;
in
{
  ###
  # Automatically generated for host, don't change
  ###
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };
  systemd.targets.multi-user.enable = true;

  networking.networkmanager.enable = true;

  services.getty.autologinUser = null;

  users.users.${vars.username} = {
    extraGroups = ["networkmanager"];
  };
}
