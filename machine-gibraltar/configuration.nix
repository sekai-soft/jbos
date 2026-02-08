{ config, lib, pkgs, ... }:

let
  vars = import ./os-etc/vars.nix;
in
{
  ###
  # Imports
  ###
  imports = [
    ./os-etc/hardware-configuration.nix
    ./os-etc/auto-generated.nix
    ../os-common/networking.nix
    (import ../os-common/locale.nix ./os-etc/vars.nix)
    ../os-common/docker.nix
    ../os-common/openssh.nix
    ../os-common/nix.nix
    ../os-common/packages.nix
    ../os-common/shell.nix
    (import ../os-common/users.nix ./os-etc/vars.nix)
    ../os-common/services.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/v1.11.0.tar.gz"}/module.nix"
    ./os-etc/disk-config.nix
  ];

  ###
  # Server specific
  ###
  networking.hostName = vars.hostname;
  services.caddy = {
    enable = true;
    virtualHosts."rsshub.ktachibana.party".extraConfig = ''
      reverse_proxy http://rsshub:1200
    '';
    virtualHosts."files.mastodon.ktachibana.party".extraConfig = ''
      root * /var/www/html

      @local file {
        try_files {path} {path}/ /index.html
      }
      handle @local {
        file_server {
          index index.html
        }
      }

      handle {
        @notGet {
          not method GET
        }
        respond @notGet 403

        reverse_proxy http://mastodon-s3.ktachibana.party.s3.us-west-1.wasabisys.com {
          header_up Host mastodon-s3.ktachibana.party.s3.us-west-1.wasabisys.com
          header_up Connection ""
          header_up Authorization ""
          header_down -Set-Cookie
          header_down -Access-Control-Allow-Origin
          header_down -Access-Control-Allow-Methods
          header_down -Access-Control-Allow-Headers
          header_down -x-amz-id-2
          header_down -x-amz-request-id
          header_down -x-amz-meta-server-side-encryption
          header_down -x-amz-server-side-encryption
          header_down -x-amz-bucket-region
          header_down -x-amzn-requestid
        }

        header {
          Cache-Control "public, max-age=31536000"
          Access-Control-Allow-Origin "*"
          X-Content-Type-Options "nosniff"
          Content-Security-Policy "default-src 'none'; form-action 'none'"
        }
      }
    '';
    virtualHosts."streaming.mastodon.ktachibana.party".extraConfig = ''
      reverse_proxy http://mastodon-streaming:4000
    '';
    virtualHosts."mastodon.ktachibana.party".extraConfig = ''
      reverse_proxy http://mastodon:3000
    '';
    virtualHosts."galerie-reader.app".extraConfig = ''
      reverse_proxy http://galerie:5000
    '';
    virtualHosts."rss-lambda.xyz".extraConfig = ''
      reverse_proxy http://rss-lambda:5000
    '';
    virtualHosts."github-org-actions.sekaisoft.tech".extraConfig = ''
      reverse_proxy http://github-org-actions:8080
    '';
    virtualHosts."status.sekaisoft.tech".extraConfig = ''
      reverse_proxy http://uptime-kuma-sekaisoft:80
    '';
  };
  services.cron.systemCronJobs = [
    "0 0 1 * * nixos /home/nixos/mastodon-cleanup/main.sh"
    "0 0 1 * * nixos /home/nixos/backup-configs/main.sh"
    "0 0 * * 0 nixos /home/nixos/report-disk-usage/main.sh"
  ];
 
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
