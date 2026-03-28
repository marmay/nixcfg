{ config, lib, pkgs, ... }:
{
  config =
  {
    nixpkgs.config.allowUnfree = true;
    # services.minecraft-servers = {
    #   enable = true;
    #   eula = true;
    #   openFirewall = true;
    #   servers = {
    #     main = {
    # 	  enable = true;
    # 	  serverProperties = {};
    # 	  whitelist = {};
    #       symlinks = {
    #         mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
    #            = fetchurl { url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/XGIsoVGT/starlight-1.1.2%2Bfabric.dbc156f.jar"; sha512 = "6b0e363fc2d6cd2f73b466ab9ba4f16582bb079b8449b7f3ed6e11aa365734af66a9735a7203cf90f8bc9b24e7ce6409eb04d20f84e04c7c6b8e34f4cc8578bb"; };
    #         });
    #       };
    # 	};
    #   };
    # };

    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;
      serverProperties = {
        server-port = 40000;
        difficulty = 1;
        gamemode = 0;
        max-players = 4;
        motd = "Mamaragach server!";
        white-list = false;
        enable-rcon = true;
        "rcon.password" = "MMSPijvdW!";
        online-mode = false;
	spawn-protection = 0;
      };
    };
    systemd.services.minecraft-server.wantedBy = lib.mkForce [];
  };
}
