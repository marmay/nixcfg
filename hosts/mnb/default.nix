{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    system.stateVersion = "24.05";

    networking = {
      hostName = "mnb";
      networkmanager.enable = true;
    };

    programs.light.enable = true;
    programs.light.brightnessKeys.enable = true;

    services.fprintd.enable = true;
    services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

    hardware.graphics.extraPackages = with pkgs; [
      vpl-gpu-rt
    ];

    marmar = {
      haskell = true;
      nas_client = true;
      intelGpuSupport = true;
      printingSupport = true;
      steam = true;
      uefi = true;
    };

    marmar.users.markus.enable = true;

    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;
    home-manager.users.markus.profiles.photo = true;
    home-manager.users.markus.profiles.school = true;
    marmar.users.marion.enable = true;
    marmar.users.raphaela.enable = true;
    marmar.users.gabriel.enable = true;
    home-manager.users.gabriel.profiles.school = true;

    # services.create_ap = {
    #   enable = true;
    #   settings = {
    #     INTERNET_IFACE = "enp0s13f0u1";
    #     WIFI_IFACE = "wlp0s20f3";
    #     SSID = "Inf5a";
    #     PASSPHRASE = "Inf5a202425";
    #     FREQ_BAND = "5";
    #     CHANNEL = "149";
    #     IEEE80211N = "1";
    #     HT_CAPAB = "[LDPC][HT40+][HT40-][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935][DSSS_CCK-40]";
    #     VHT_CAPAB = "[MAX-MPDU-11454][RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE]";
    #   };
    # };

    # networking.firewall.allowedTCPPorts = [ 80 ];
    # services.davinci-convert = {
    #   enable = true;
    #   ffmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
    #   port = 3000;
    #   basePath = "/convert";
    #   fileBase = "/var/lib/davinci-convert";
    #   nginx = {
    #     enable = true;
    #   };
    # };
  };
}
