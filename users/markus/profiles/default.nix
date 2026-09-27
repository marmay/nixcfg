{ config, lib, pkgs, ... }:
{
  imports = [ ./agda ./dev ./gui ./latex ./photo ./school ./sway ];

  # Let home-manager own the bash start-up files. Its ~/.profile sources the
  # session variables (EDITOR etc.), which the NixOS session wrapper picks up
  # at login, so xmonad and everything it spawns see them too.
  programs.bash = {
    enable = true;

    # Machine-local additions such as credentials stay out of the repository.
    initExtra = ''
      if [ -f ~/.bashrc.local ]; then
        . ~/.bashrc.local
      fi
    '';
  };
}
