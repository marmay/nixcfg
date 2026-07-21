{ config, lib, pkgs, inputs, ... }:
{
  config =
  {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
    nixpkgs.config.allowUnfree = true;
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers = {
        main = {
    	  enable = true;
          package = pkgs.fabricServers.fabric-1_20_1;
    	  serverProperties = {};
    	  whitelist = {};
          symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
              VillagerRecruits = pkgs.fetchurl {
	        url = "https://cdn.modrinth.com/data/WOg9lm4u/versions/2zXpVxK4/recruits-1.20.1-1.15.2.jar";
		sha512 = "4e96966eca175cc362d5b675c3c08a70ad8ae15b058b445d93b1db95ff87e2cac8ffa37e7e9218d46df52ad704389642d7bda1d4cfa9581ac2d62553d708f61f";
	      };
	      VillagerWorkers = pkgs.fetchurl {
	        url = "https://cdn.modrinth.com/data/Pqlv7VM3/versions/49csRXJc/workers-1.20.1-2.0.3.jar";
		sha512 = "6638b58232ba8f60aecbe4fcae7884f91ec281a6e1f254d6a9b97b95b00c6e8a6f66c368e6539c84afe58b55f4dafee2bedca572c70cd6655f58850a9d4670fd";
	      };
	      SiegeWeapons = pkgs.fetchurl {
	        url = "https://cdn.modrinth.com/data/d4elsJgD/versions/wtETPu9o/siegeweapons-1.20.1-0.2.5.jar";
		sha512 = "e2b782b39e5209d831ea5074348120ac0ebe31b94e583fcd97e26030d2fb2c234ac8a1ad2c313c7d0738b80a3908da4ad7c21ce3214fa3da941082e19fdc111d";
	      };
	      SmallShips = pkgs.fetchurl {
	        url = "https://cdn.modrinth.com/data/rGWEHQrP/versions/58DKgNnY/smallships-forge-1.20.1-2.0.0-b1.4.jar";
		sha512 = "96eb4b05e2ca71e6f608811da0e1687a9744421b84e7c876e9a36cd2cdc30bf3c7174525c0915f87be30bd840d39f7b7aa8e0dde19747a495ff5c1a57b701dac";
	      };
            });
          };
    	};
      };
    };

    # services.minecraft-server = {
    #   enable = true;
    #   eula = true;
    #   openFirewall = true;
    #   declarative = true;
    #   serverProperties = {
    #     server-port = 40000;
    #     difficulty = 1;
    #     gamemode = 0;
    #     max-players = 4;
    #     motd = "Mamaragach server!";
    #     white-list = false;
    #     enable-rcon = true;
    #     "rcon.password" = "MMSPijvdW!";
    #     online-mode = false;
    # 	spawn-protection = 0;
    #   };
    # };
    # systemd.services.minecraft-server.wantedBy = lib.mkForce [];
  };
}
