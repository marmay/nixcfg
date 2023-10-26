{ config, lib, pkgs, ... }:
{
  config =
  {
    nixpkgs.config.allowUnfree = true;
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;
      serverProperties = {
        server-port = 40000;
        difficulty = 1;
        gamemode = 0;
        max-players = 2;
        motd = "Mamaragach server!";
        white-list = false;
        enable-rcon = true;
        "rcon.password" = "MMSPijvdW!";
        online-mode = false;
      };
    };
    systemd.services.minecraft-server.wantedBy = lib.mkForce [];
  };
}
