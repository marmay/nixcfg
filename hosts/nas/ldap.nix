{ config, lib, ... }:
{
#  users.ldap = {
#    enable = true;
#    loginPam = true;
#    base = "ou=People,dc=home";
#    server = "ldap://ldap.local";
#    useTLS = false;
#    daemon = {
#      enable = true;
#      rootpwmoddn = "cn=admin,dc=home";
#      rootpwmodpwFile = "/etc/ldap/bind.password";
#    };
#    extraConfig = ''
#      nss_override_attribute_value loginShell /run/current-system/sw/bin/bash
#    '';
#    bind = {
#      distinguishedName = "cn=admin,dc=home";
#      policy = "soft";
#    };
#  };
#
#  security.pam.services.login.makeHomeDir = true;
#  config.services.sssd = {
#    enable = true;
#    config = ''
#      [sssd]
#      config_file_version = 2
#      services = nss, pam
#      domains = ldap.local
#
#      [domain/ldap.local]
#      debug_level = 5
#      auth_provider = ldap
#      id_provider = ldap
#      ldap_uri = ldap://ldap.local:389
#      ldap_search_base = ou=People,dc=home
#      ldap_default_bind_dn = cn=admin,dc=home
#      ldap_default_authtok_type = password
#      ldap_default_authtok = M4rj4N12!
#      ldap_id_use_start_tls = False
#      ldap_tls_reqcert = allow
#    '';
#  };
}
