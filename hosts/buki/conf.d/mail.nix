{ config, pkgs, ... }:

let release = "nixos-22.11";
in {
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      sha256 = "1i56llz037x416bw698v8j6arvv622qc0vsycd20lx3yx8n77n44";
    })
  ];

  config.age.secrets = {
    mailHashedPwdGabriel.file = ../../../secrets/markus/mail/hashed_pwd.gabriel;
    mailHashedPwdMarion.file = ../../../secrets/markus/mail/hashed_pwd.marion;
    mailHashedPwdMarkus.file = ../../../secrets/markus/mail/hashed_pwd.markus;
    mailHashedPwdRaphaela.file = ../../../secrets/markus/mail/hashed_pwd.raphaela;
  };

  config.mailserver = {
    enable = true;
    fqdn = "mail.bu-ki.at";
    domains = [ "bu-ki.at" "marion-mayr.at" ];
    loginAccounts = {
      "markus@bu-ki.at" = {
        hashedPasswordFile = config.age.secrets.mailHashedPwdMarkus.path;
        aliases = [
          "abuse@bu-ki.at"
          "postmaster@bu-ki.at"
        ];
      };
      "marion@marion-mayr.at" = {
        hashedPasswordFile = config.age.secrets.mailHashedPwdMarion.path;
        aliases = [
          "office@marion-mayr.at"
          "kontakt@marion-mayr.at"
        ];
      };
      "raphaela@marion-mayr.at" = {
        hashedPasswordFile = config.age.secrets.mailHashedPwdRaphaela.path;
      };
      "gabriel@marion-mayr.at" = {
        hashedPasswordFile = config.age.secrets.mailHashedPwdGabriel.path;
      };
    };
  };
}
