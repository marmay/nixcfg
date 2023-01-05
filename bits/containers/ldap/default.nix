{ lib, pkgs, config, ... }:
let commonContainerConfig = import ../common;
in
{
  config = {
    age.secrets = {
      ldapVpnCaCert = {
        file = ../../../secrets/markus/vpn/server/buki/cert;
      };
      ldapVpnClientCert = {
        file = ../../../secrets/markus/vpn/client/ldap/cert;
      };
      ldapVpnClientKey = {
        file = ../../../secrets/markus/vpn/client/ldap/key;
      };
      ldapVpnTaKey = {
        file = ../../../secrets/markus/vpn/server/buki/ta.key;
      };
    };

    containers.ldap =
      let
        ageSecrets = config.age.secrets;
      in commonContainerConfig.containerNetwork // {
      autoStart = true;
      enableTun = true;

      bindMounts = {
        "/run/agenix" = {
          hostPath = "/run/agenix";
          isReadOnly = true;
        };
        "/run/agenix.d" = {
          hostPath = "/run/agenix.d";
          isReadOnly = true;
        };
      };
      config = { config, pkgs, ... }: {
        imports = [
          ../../system/vpn_client.nix
        ];

        system.stateVersion = "22.05";
        networking.interfaces.eth0.useDHCP = true;
        networking.firewall.allowedTCPPorts = [ 389 ];

        openvpnCfg = {
          enable = true;
          host = "marion-mayr.at";
          serverCert = "/run/agenix/1/ldapVpnCaCert";
          clientCert = "/run/agenix/1/ldapVpnClientCert";
          clientKey = "/run/agenix/1/ldapVpnClientKey";
          taKey = "/run/agenix/1/ldapVpnTaKey";
        };

        services.openldap = {
          enable = true;

          settings = {
            attrs.olcLogLevel = [ "stats" ];
            children = {
              "cn=schema".includes = [
                 "${pkgs.openldap}/etc/schema/core.ldif"
                 "${pkgs.openldap}/etc/schema/cosine.ldif"
                 "${pkgs.openldap}/etc/schema/nis.ldif"
                 "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
              ];
              "olcDatabase={1}mdb" = {
                attrs = {
                  objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
                  olcDatabase = "{1}mdb";
                  olcDbDirectory = "/var/lib/openldap/users";
                  olcSuffix = "dc=home";
                  olcRootDN = "cn=admin,dc=home";
                  olcRootPW = "{SSHA}c/XDM3STbGYG4JBsd6XbM319Aqwm8xIc";
                  olcAccess = [
                    ''{0}to * by * read''
                  ];
                  olcDbIndex = [
                    "objectClass eq"
                    "cn pres,eq"
                    "uid pres,eq"
                    "sn pres,eq,subany"
                  ];
                };
              };
            };
          };

          declarativeContents."dc=home" = builtins.readFile ./users.ldif;
        };
      };
    };
  };
}

