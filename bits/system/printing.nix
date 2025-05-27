{ config, lib, self, pkgs, ... }:
{
  options.marmar.printingSupport = lib.mkEnableOption "Printing Support";

  config = lib.mkIf config.marmar.printingSupport {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      printing = {
        enable = true;
	stateless = true;
        browsing = true;
	browsed.enable = true;
        defaultShared = false;
	drivers = with pkgs; [ gutenprint ];
      };
    };
  };
}
