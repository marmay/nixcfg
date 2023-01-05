{ lib, pkgs, config, ... }:
let commonContainerConfig = import ../common;
    baseServicePath = commonContainerConfig.path.serviceBase + "/music";

    servicePaths =
      [ { "host" = "music/snapcast"; "container" = "/var/lib/snapcast"; }
        { "host" = "music/mopidy"; "container" = "/var/lib/container"; }
      ];

    mopidyUsers =
      [ { "name" = "marion";    "port" = "6680"; }
        { "name" = "markus";    "port" = "6681"; }
        { "name" = "raphaela";  "port" = "6682"; }
        { "name" = "gabriel";   "port" = "6683"; }
        { "name" = "charlotte"; "port" = "6684"; }
      ];

    mopidyEnv = pkgs.buildEnv {
      name = "mopidy-with-extensions-${pkgs.mopidy.version}";
      paths = lib.closePropagation [
        pkgs.mopidy
        pkgs.mopidy-iris
        pkgs.mopidy-local
        pkgs.mopidy-youtube
      ];
      pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
          --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
      '';
    };

    mkMopidyService = user : {
      "mopidy_${user.name}" = {
        wantedBy = [ "multi-user.target" ];
	after = [ "network-online.target" ];
	wants = [ "network-online.target" ];
	description = "Start mopidy service for user ${user.name} at port ${user.port}.";
	serviceConfig = {
	  type = "forking";
	  User = "mopidy";
	  ExecStart = ''${mopidyEnv}/bin/mopidy --config /etc/mopidy/common.conf -o "http/port=${user.port}" -o "audio/output=audioresample ! audio/x-raw,rate=48000,channels=2,format=S16LE ! audioconvert ! wavenc ! filesink location=/run/snapserver/pipe_${user.name}"'';
	};
      };
    };

    mkSnapcastPipe = user : {
      "pipe_${user.name}" = {
        type = "pipe";
        location = "/run/snapserver/pipe_${user.name}";
      };
    };
in
{
  config = {
    system.activationScripts.makeMusicContainerDirs =
      commonContainerConfig.path.mkServicePathActivations
        servicePaths;
  
    containers.music = commonContainerConfig.containerNetwork // {
      autoStart = true;
  
      bindMounts = {
        "/srv/music" = {
          hostPath = commonContainerConfig.path.music;
          isReadOnly = true;
        };
      } // (lib.lists.foldr lib.attrsets.recursiveUpdate {} (commonContainerConfig.path.mkServicePathBinds servicePaths));
  
      config = { config, pkgs, ... }: {
        system.stateVersion = "22.05";
        nixpkgs.config.allowUnfree = true;
  
        networking.interfaces.eth0.useDHCP = true;
        networking.firewall.allowedTCPPorts = [ 80 6680 6681 6682 6683 6684 ];
  
        users.users.mopidy = {
          isSystemUser = true;
          group = "nogroup";
          extraGroups = [ "audio" ];
          description = "Mopidy daemon user";
          home = "/var/lib/mopidy";
  	createHome = true;
        };
  
        environment.etc."mopidy/common.conf".source = ./mopidy/common.conf;
  
        systemd.services = lib.lists.foldr lib.attrsets.recursiveUpdate {} (map mkMopidyService mopidyUsers);
  
        services.snapserver = {
          enable = true;
          codec = "flac";
          streams = (lib.lists.foldr lib.attrsets.recursiveUpdate {} ((map mkSnapcastPipe mopidyUsers)));
        };
  
        services.nginx = {
          enable = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
  	virtualHosts."static" = {
  	  root = "/etc/www";
  	};
        };
  
        environment.etc."www/index.html".text = 
        let mkUserLink = user : ''<li><a href="/iris" onclick="javascript:event.target.port=${user.port}">${user.name}</a></li>'';
        in
        ''
          <html>
  	<head>
  	<title>Musikserver</title>
  	</head>
  	<body>
  	<h1>Bitte Benutzer w&auml;hlen:</h1>
  	<ul>
  	  ${lib.strings.concatStrings (builtins.map mkUserLink mopidyUsers)}
  	</ul>
  	</body>
  	</html>
        '';
      };
    };
  };
}
