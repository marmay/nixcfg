{ config, lib, pkgs, ... }:
{
  config = {
    age.secrets = lib.mkIf config.services.spotifyd.enable {
      "spotifyPassword" = {
        file = ../../secrets/markus/spotify;
        owner = "spotifyd";
      };
    };

    services.spotifyd.settings.global = {
      username = "marmayr";
      password_cmd = "cat ${config.age.secrets.spotifyPassword.path}";
      device_name = "${config.networking.hostName}";
      device_type = "speaker";
    };
  };
}
