{ inputs, config, pkgs, ... }:
let
  public_keys = import ../../secrets/aws_public.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  config = {
    boot.loader.systemd-boot.enable = true;

    networking.hostName = "bu-ki"; # Define your hostname.

    # Set your time zone.
    time.timeZone = "Europe/Vienna";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.ens3.useDHCP = true;

    # Select internationalisation properties.
    i18n.defaultLocale = "de_AT.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.markus = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
    users.users.root.openssh.authorizedKeys.keys = [
      public_keys.host
    ];

    nix.settings.trusted-users = [ "root" "markus" ];

    # List packages installed in system profile. To search, run:
    environment.systemPackages = with pkgs; [
      git
      htop
      inputs.bghorn.packages.${pkgs.stdenv.hostPlatform.system}.bghorn-restore
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.settings.GatewayPorts = "clientspecified";

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 80 143 443 587 2222 8443 ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?

    security = {
      acme.certs."bu-ki.at".email = "markus@bu-ki.at";
      acme.acceptTerms = true;
    };

    age.secrets = {
      marmay-auth-security-config = {
        file = ../../secrets/markus/bu-ki/marmay-auth-security-config;
        owner = "marmay-auth";
        mode = "0400";
      };
      bghorn-cms-security-config = {
        file = ../../secrets/markus/bu-ki/bghorn-cms-security-config;
        owner = "bghorn";
        mode = "0400";
      };
      bghorn-cms-publisher-ftp-password= {
        file = ../../secrets/markus/bu-ki/bghorn-cms-publisher-ftp-password;
        owner = "root";
        mode = "0400";
      };
      competences-m2a-security-config = {
        file = ../../secrets/markus/bu-ki/competences-m2a-security-config;
	owner = "competences_m2a";
	mode = "0400";
      };
    };

    services = {
      nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;

        virtualHosts."bu-ki.at" = {
          enableACME = true;
          forceSSL = true;
          locations."~ ^/~(.+?)(/.*)?$".extraConfig = ''
            alias /srv/public_html/$1$2;
            index  index.html index.htm;
            autoindex on;
          '';
        };
      };

      bghorn.backend = {
        enable = true;
        securityConfigFile = config.age.secrets.bghorn-cms-security-config.path;
	backup = {
	  enable = true;
	};
      };
      bghorn.builder = {
        enable = true;
        preview = {
          enable = true;
          domain = "preview.cms.bu-ki.at";
        };
      };
      bghorn.proxy = {
        enable = true;
        domain = "cms.bu-ki.at";
        acmeEmail = "markus@bu-ki.at";
      };
      bghorn.publisher = {
        enable = true;
        host = "wh3.asn-noe.ac.at";
        user = "cms-publisher";
        passwordFile = config.age.secrets.bghorn-cms-publisher-ftp-password.path;
	caFile = ./asn-fortigate-ca.pem;
        dryRun = false;
      };
      marmay-auth = {
        enable = true;
        port = 43000;
        secretsFile = config.age.secrets.marmay-auth-security-config.path;
        nginx.enable = true;
        nginx.domain = "bu-ki.at";
      };
      competences = {
        enable = true;
	instances = {
	  m2a = {
	    port = 43210;
	    subdomain = "m2a";
	    database = "competences_m2a";
	    secretsFile = config.age.secrets.competences-m2a-security-config.path;
	    ensureTeacherO365 = "240fec71-f179-4a6d-9e81-b5f65a869ef4";
	  };
	};
	nginx = {
	  enable = true;
	  domain = "bu-ki.at";
	  enableACME = true;
	  forceSSL = true;
	};
        postgresql.enable = true;
      };
    };
  };
}

