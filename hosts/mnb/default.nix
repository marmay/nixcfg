{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.enableContainers = true;

    system.stateVersion = "24.05";

    networking = {
      hostName = "mnb";
      networkmanager.enable = true;
    };
    hardware.acpilight.enable = true;
    programs.localsend.enable = true;

    services.fprintd.enable = true;
    services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

    services.postgresql.enable = true;
    services.postgresql.ensureUsers = [ { name = "markus"; ensureDBOwnership = true; ensureClauses = { superuser = true; }; } ];
    services.postgresql.ensureDatabases = [ "markus" "competences_test" ];

    services.syncthing.enable = true;
    
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.docker.enable = true;
    programs.virt-manager.enable = true;
    users.users.markus.extraGroups = [ "docker" "libvirtd" "kvm" "render" "video" ];   

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
      xmonad = true;
    };

    marmar.users.markus.enable = true;

    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.gui = true;
    home-manager.users.markus.profiles.photo = true;
    home-manager.users.markus.profiles.school = true;
    marmar.users.marion.enable = true;
    marmar.users.raphaela.enable = true;
    marmar.users.gabriel.enable = true;
    home-manager.users.gabriel.profiles.school = true;

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
