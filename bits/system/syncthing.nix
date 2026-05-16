{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    user = "markus";
    dataDir = "/home/markus";
    configDir = "/home/markus/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;   # NixOS ist Source of Truth, GUI-Änderungen werden überschrieben
    overrideFolders = true;

    settings = {
      devices = {
        "mnb" = { id = "N24YM3P-BUDBBAA-KVN6OTS-PLNHFGA-HTMHLPU-QLKDBUC-3DKISCJ-DGWIPQX"; };
	"keller" = { id = "ZOJN22D-HSOKKZD-HPRBCDI-GVOKI7C-5JYQVPY-7EDCX6V-5B6MOXC-ZILOIA5"; };
	"phone" = { id = "FGWF2AM-27DJLKG-KLJN7Z2-R7BB2IP-MI3UPGB-6VDSTZ2-QZ3IGLW-HWUF2AZ"; };
      };
      folders."org" = {
        id = "org-files";                  # muss auf allen Geräten identisch sein
        path = "/home/markus/org";
        devices = [ "mnb" "keller" "phone" ];
      };
    };
  };
}