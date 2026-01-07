{ ... }:

{
  services.tailscale.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = [ ];
  };
}
