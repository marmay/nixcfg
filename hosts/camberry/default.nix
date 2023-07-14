{config, lib, pkgs, ...}:
{
  config = {
    nixpkgs = {
      crossSystem.system = "armv6l-linux";
      overlays = [
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    };

    # Make the image a bit smaller:
    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    security.polkit.enable = false;
    services.udisks2.enable = false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    # Use a stripped down systemd, as we do not want Cryptsetup in particular.
    systemd.package = pkgs.systemd.override {
      pname = "systemd-small";

      withTimesyncd = true;
      withLogind = true;

      withNetworkd = false;
      withOomd = false;

      withAnalyze = false;
      withApparmor = false;
      withCompression = false;
      withCoredump = false;
      withCryptsetup = false;
      withDocumentation = false;
      withEfi = false;
      withFido2 = false;
      withHostnamed = false;
      withHwdb = false;
      withImportd = false;
      withLibBPF = false;
      withLocaled = false;
      withMachined = false;
      withNss = false;
      withPCRE2 = false;
      withPolkit = false;
      withPortabled = false;
      withRemote = false;
      withResolved = false;
      withShellCompletions = false;
      withTimedated = false;
      withTpm2Tss = false;
      withUserDb = false;
    };

    # Disable some features, because we compiled without support for it.
    systemd.network.enable = false;
    systemd.oomd.enable = false;
    systemd.coredump.enable = false;

    # Enable WLAN & Hifiberry support:
    hardware.firmware = with pkgs; [ raspberrypiWirelessFirmware ];
    hardware.deviceTree.enable = true;
    hardware.deviceTree.overlays = [ "${config.boot.kernelPackages.kernel}/dtbs/overlays/hifiberry-dac.dtbo" ];

    # Configure network in general
    networking = {
      hostName = "rpizero1";
      useDHCP = false;

      interfaces = {
        wlan0 = {
          useDHCP = true;
        };
      };

      # Configure wireless connection:
      wireless.enable = true;
      wireless.networks."MarMarX".psk = "M4rj4N12!";

      # Configure firewall:
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
    };

    # Enable spotifyd
    services.spotifyd = {
      enable = true;
      settings.global = {
        username = "marmayr";
        password = "1beV3G00";
        device_name = "Raphis_CD_Player";
        device_type = "speaker";
      };
    };

    # Enable OpenSSH out of the box.
    services.sshd.enable = true;
    users.users."root".openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM5PopmbJTKDVIEWZxIs4Yvc7kkmbOi7GFjTNVXEMY0qyODq0stLfmKqdfx4D90nirTpvteKEq1akR57YFdie+UdUPPPl0vQDiNtIq+bPQ2cP3MEVqHpsKNpHRHVPepLRMRF30f5l1+E9sKgjtJt49vX9JD71dtYnsbIgsu4rZJx3sa/df+FEcOt9C7VtfIBAFg/gR2Zk9swXwelIesiNX7dfFJRnfnksX0IPssUauyA52PzTe4NH/5LTnWIuVYFnN2YEe1vp5pcc3VGHCFkRoqHpfCp4bz6tYLG1biw5ixkP1XqQylgwWTN1Iy0TWCf38HVPK1EFbvVVEb1YGlY1qU6ED0NCU9T1r0fNBq9J0mZ9jCWavNavRGLw7invw+yEQ5hI1VmMtlp42vuUxwkPDAk2oTdWyl0kDH+etpbSDqu6e4TcQ9RqK/UUmC56sKv6FzEDwcCgswSgXL6dkZaXw3Fo6YrdGlFohmwW3B7jzVgSAugtEj9XEN4PMnAd1GY0= markus@keller"
    ];

    system.stateVersion = "23.05"; # Did you read the comment?
  };
}
