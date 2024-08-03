{config, lib, pkgs, ... }:
{
  imports = [];

  config = {
    programs = {
      firefox.enable = true;
    };
  };
}

