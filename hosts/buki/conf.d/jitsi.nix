{ pkgs, config, ... }:
{
  config.services.jitsi-meet = {
    enable = true;
    hostName = "meet.marion-mayr.at";
  };
}
