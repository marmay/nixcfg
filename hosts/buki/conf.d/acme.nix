{ pkgs, config, ... }:
{
  config.security = {
    acme.certs."bu-ki.at".email = "markus@bu-ki.at";
    acme.certs."marion-mayr.at".email = "office@marion-mayr.at";
    acme.certs."meet.marion-mayr.at".email = "office@marion-mayr.at";
    acme.certs."cloud.marion-mayr.at".email = "office@marion-mayr.at";
    acme.certs."media.marion-mayr.at".email = "office@marion-mayr.at";
    acme.acceptTerms = true;
  };
}

