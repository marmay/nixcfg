{ config, lib, pkgs, inputs, ... }:
let
  mcVersion = "1.20.1";
  forgeBuild = "47.3.22";                       # pick current 1.20.1 build
  forgeVersion = "${mcVersion}-${forgeBuild}";
  jre = pkgs.temurin-bin-17;                    # 1.20.1 wants Java 17

  installer = pkgs.fetchurl {
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${forgeVersion}/forge-${forgeVersion}-installer.jar";
    hash = "sha256-uB4WO6JAvkr269z92xPvZcoX/Grrylyu2iBoxH2rzPs=";
  };

  forge-server = pkgs.writeShellScriptBin "minecraft-server" ''
    if [ ! -f libraries/net/minecraftforge/forge/${forgeVersion}/unix_args.txt ]; then
      ${jre}/bin/java -jar ${installer} --installServer
      rm -f installer.log run.sh run.bat user_jvm_args.txt
    fi
    exec ${jre}/bin/java "$@" \
      @libraries/net/minecraftforge/forge/${forgeVersion}/unix_args.txt nogui
  '';
in
{
  config =
  {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
    nixpkgs.config.allowUnfree = true;
    networking.firewall.allowedUDPPorts = [ 24454 ];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers = {
        main = {
          enable = true;
          package = forge-server;
          serverProperties = {
            online-mode = false;
          };
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
              DrinkBeerRefill = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/RZwVw5iA/versions/rOSCLvXP/drinkbeer-refill-1.20.1-1.0.5.jar";
                sha512 = "f78966887ff311e359cd32dd8113e4c95592dd731cd9e21db4feb9e3fbe36e6e3b1288c19665dade0a3edd139ac97400a3e1b9cbbff99f80a629b20da6b2efd4";
              };
              AnotherFurniture = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/ulloLmqG/versions/S9tNKT5R/another_furniture-forge-1.20.1-3.0.4.jar";
                sha512 = "c57011a7e078cdb05ca05123d2ca3d01b1f3baca3555c067150e23d75268bb250b45a780da1488a49c08c46f6ed38e883f6cd47981babffe43b5f501984f1afc";
              };
	      SimpleVoiceChat = pkgs.fetchurl {
	        url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/S11m0QIb/voicechat-forge-1.20.1-2.6.22.jar";
                sha512 = "I8izpZP+UGr42ODtwK+0U0l3fVzepB/8P6ma/C47m8d3C7mVH2dAF+pbPCPhEbDGAx69YYIMmgtRkeOZLZyHmA==";
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
    #         spawn-protection = 0;
    #   };
    # };
    # systemd.services.minecraft-server.wantedBy = lib.mkForce [];
  };
}
