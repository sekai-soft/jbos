{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    jq
    nano
    rsync
    tmux
    wget
  ];

  documentation.enable = false;
}
