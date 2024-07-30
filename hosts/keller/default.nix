{ config, lib, pkgs, ... }:

let
    port = 3128;
    client_ip = "10.0.0.20";
in
{
  imports = [
    ./hardware.nix
    ./minecraft.nix
  ];

  config = {
    system.stateVersion = "22.05";

    networking = {
      hostName = "keller";
      interfaces.enp5s0 = {
        wakeOnLan.enable = true;
      };
      firewall.allowedTCPPorts = [ 80 443 port (port + 1)];
      extraHosts = ''
        10.0.0.10 webuntis.local
      '';
    };

    virtualisation.docker.enable = true;

    hardware.keyboard.qmk.enable = true;
    nix.gc.automatic = false;

    marmar = {
      haskell = true;
      nas_client = true;
      nvidiaGpuSupport = true;
      printingSupport = true;
      scanningSupport = true;
      swaySupport = true;
      steam = true;
      uefi = true;
      xrdp = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.markus.extraGroups = [ "cdrom" "video" "render" ];
    home-manager.users.markus.profiles.agda = true;
    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;
    home-manager.users.markus.profiles.sway = true;
    home-manager.users.markus.profiles.work = true;
    home-manager.users.markus.profiles.photo = true;

    marmar.users.raphaela.enable = true;
    home-manager.users.raphaela.profiles.school = true;

    virtualisation.waydroid.enable = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    environment.etc."sysctl.d/99-for-hogwarts-legacy.conf".text = ''
      vm.max_map_count=1048576
    '';

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "555.52.04";
      sha256_64bit = "sha256-nVOubb7zKulXhux9AruUTVBQwccFFuYGWrU1ZiakRAI=";
      sha256_aarch64 = lib.fakeSha256;
      openSha256 = lib.fakeSha256;
      settingsSha256 = "sha256-PMh5efbSEq7iqEMBr2+VGQYkBG73TGUh6FuDHZhmwHk=";
      persistencedSha256 = lib.fakeSha256;
    };

    nixpkgs.config.permittedInsecurePackages = [
      "squid-6.8"
    ];

    services.squid = {
      enable = true;
      proxyAddress = "10.0.0.10";
      proxyPort = port;
      extraConfig = ''
        acl client_device src ${client_ip}
        http_access allow client_device

        http_port ${toString (port + 1)} intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB
        acl step1 at_step SslBump1
        ssl_bump peek step1
        ssl_bump bump all

        sslcrtd_program ${pkgs.squid}/libexec/security_file_certgen -s /var/cache/squid/ssl_db -M 4MB
        sslcrtd_children 8 startup=1 idle=1
      '';
    };
  };
}
