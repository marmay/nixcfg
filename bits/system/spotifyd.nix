{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.services.spotifyd.enable {
    age.secrets = {
      "spotifyPassword" = {
        file = ../../secrets/markus/spotify;
        owner = "spotifyd";
      };
    };

    users.users.spotifyd = {
       isSystemUser = true;
       group = "spotifyd";
       extraGroups = [ "audio" "pulse-access" ];
    };

    users.groups.spotifyd = {};

    services.spotifyd.settings.global = {
      username = "marmayr";
      password_cmd = "cat ${config.age.secrets.spotifyPassword.path}";
      device_name = "${config.networking.hostName}";
      device_type = "speaker";
    };
  };
}
