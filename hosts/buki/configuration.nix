# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./conf.d/acme.nix
      ./conf.d/jitsi.nix
      ./conf.d/mail.nix
      ./conf.d/nextcloud.nix
      ./conf.d/nginx.nix
      ./conf.d/openvpn.nix
      ./conf.d/postgresql.nix
      ./cachix.nix
      /home/markus/kindergartenbuecherei/service.nix
    ];

  config = {
    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    # Define on which hard drive you want to install Grub.
    boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  
    networking.hostName = "marmar"; # Define your hostname.
  
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
  
    nix.trustedUsers = [ "root" "markus" ];
  
    # List packages installed in system profile. To search, run:
    environment.systemPackages = with pkgs; [
      cachix
      gnupg
      goaccess
      git
      htop
      vim
    ];
  
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  
    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 80 143 443 587 ];
    networking.firewall.allowedUDPPorts = [ 1194 ];
  
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.11"; # Did you read the comment?
  };
}

