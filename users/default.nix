{ config, lib, pkgs, ... }:
{
  config.marmar.users.markus = {
    uid = 1000;
    trusted = true;
    admin = true;
    passwordFile = ../secrets/markus/users/markus;
  };

  config.marmar.users.marion = {
    uid = 1001;
    trusted = false;
    admin = false;
    passwordFile = ../secrets/markus/users/marion;
  };

  config.marmar.users.raphaela = {
    uid = 1002;
    trusted = false;
    admin = false;
    passwordFile = ../secrets/markus/users/raphaela;
  };

  config.marmar.users.gabriel = {
    uid = 1003;
    trusted = false;
    admin = false;
    passwordFile = ../secrets/markus/users/gabriel;
  };
}
