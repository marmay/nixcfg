{ config, lib, self, pkgs, ... }:
{
  options.marmar.printingSupport = lib.mkEnableOption "Printing Support";

  config = lib.mkIf config.marmar.printingSupport {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
      };

      printing = {
        enable = true;
	browsed.enable = false;
        defaultShared = false;
	drivers = with pkgs; [ gutenprint brlaser ];
      };
    };
  };
}
