{ config, lib, pkgs, ... }:
let user = "markus"; in
{
  config = {
    users.users.${user}.extraGroups = [
      "wheel"
    ];
  };
}
