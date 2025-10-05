{ config, lib, pkgs, nixosConfig, ... }:

{
  options = {
    marmar.xsession.xmonad = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable xmonad";
      };
      onlyStartServicesForXsession = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''dunst, polybar and udiskie are only run automatically for
                        the Xsession, not in other sessions.'';
      };
    };
  };

  config = lib.mkIf config.marmar.xsession.xmonad.enable {
    home.packages = [
      pkgs.dmenu
      pkgs.feh
      pkgs.flameshot
      pkgs.pass
      pkgs.onboard
    ];

    xsession.enable = true;
    xsession.initExtra = ''
      if test "$(echo $(basename $1) | sed -e 's/[^-]*-\(.*\)/\1/')" != "xsession"; then
        echo "$(basename $1)" > /tmp/xsession.log;
        eval exec "$@";
      fi
      feh --bg-scale ~/.background.jpg &
    '';

    xsession.windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [ haskellPackages.dbus ];
      enableContribAndExtras = true;
      config = ./config.hs;
    };

    programs.kitty.enable = lib.mkDefault true;
    programs.rofi.enable = lib.mkDefault true;

    services = {
      dunst.enable = lib.mkDefault true;
      polybar.enable = lib.mkDefault true;
      udiskie.enable = lib.mkDefault true;
      screen-locker.enable = lib.mkDefault true;
      screen-locker.lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
    };

    systemd.user.services = lib.mkIf config.marmar.xsession.xmonad.onlyStartServicesForXsession {
      dunst.Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
      polybar.Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
      udisikie.Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
      xss-lock.Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
      xss-lock.Install.WantedBy = lib.mkForce [ "hm-graphical-session.target" ];
      xautolock.Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
      xautolock.Install.WantedBy = lib.mkForce [ "hm-graphical-session.target" ];
      xautolock.Service.ExecStart = lib.mkForce "${pkgs.xautolock}/bin/xautolock -time 10 -locker ${pkgs.xsecurelock}/bin/xsecurelock -detectsleep";
    };
  };
}
