{ config, pkgs, ... }:
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
      vim
      haskellPackages.hprox
      screen
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
      acme.certs."mail.bu-ki.at".email = "markus@bu-ki.at";
      acme.certs."cloud.marion-mayr.at".email = "office@marion-mayr.at";
      acme.acceptTerms = true;
    };

    age.secrets = {
      mailHashedPwdGabriel.file = ../../secrets/markus/mail/hashed_pwd.gabriel;
      mailHashedPwdMarion.file = ../../secrets/markus/mail/hashed_pwd.marion;
      mailHashedPwdMarkus.file = ../../secrets/markus/mail/hashed_pwd.markus;
      mailHashedPwdRaphaela.file = ../../secrets/markus/mail/hashed_pwd.raphaela;
    };

    mailserver = {
      enable = true;
      fqdn = "mail.bu-ki.at";
      domains = [ "bu-ki.at" "marion-mayr.at" ];
      loginAccounts = {
        "markus@bu-ki.at" = {
          hashedPasswordFile = config.age.secrets.mailHashedPwdMarkus.path;
          aliases = [
            "abuse@bu-ki.at"
            "postmaster@bu-ki.at"
          ];
        };
        "marion@marion-mayr.at" = {
          hashedPasswordFile = config.age.secrets.mailHashedPwdMarion.path;
          aliases = [
            "office@marion-mayr.at"
            "kontakt@marion-mayr.at"
          ];
        };
        "raphaela@marion-mayr.at" = {
          hashedPasswordFile = config.age.secrets.mailHashedPwdRaphaela.path;
        };
        "gabriel@marion-mayr.at" = {
          hashedPasswordFile = config.age.secrets.mailHashedPwdGabriel.path;
        };
      };
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;
        hostName = "cloud.marion-mayr.at";
        https = true;

        autoUpdateApps.enable = true;
        autoUpdateApps.startAt = "05:00:00";

        settings.overwrite-protocol = "https";

        config = {
          # Further forces Nextcloud to use HTTPS
          adminpassFile = "/var/nextcloud-admin-pass";
          adminuser = "admin";
        };
      };

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
        virtualHosts."mail.bu-ki.at" = {
          enableACME = true;
          forceSSL = true;
        };
        virtualHosts."cloud.marion-mayr.at" = {
          enableACME = true;
          forceSSL = true;
        };
      };
    };

    systemd.services.hprox = {
      description = "An HTTPS proxy";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
	ExecStart = "${pkgs.haskellPackages.hprox}/bin/hprox -p 8443 --tls bu-ki.at:/var/lib/acme/bu-ki.at/cert.pem:/var/lib/acme/bu-ki.at/key.pem";
	Type = "simple";
      };
    };
  };
}

