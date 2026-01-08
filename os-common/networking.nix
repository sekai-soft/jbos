{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 22 80 443 7844 ];
  networking.firewall.allowedUDPPorts = [ 7844 ];
}
