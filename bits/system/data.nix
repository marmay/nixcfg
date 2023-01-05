{ config, lib, pkgs, ... }:
{
  options.sharedData = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Whether to enable support for remote user data.";
    };

    path = lib.mkOption {
      default = "/media/nas";
      type = lib.types.path;
      description = "Where user data and shared data is located.";
    };
  };
}

