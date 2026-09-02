let
  keys = import ../keys.nix;
in
{
  "m365_competences_1a.config".publicKeys = [ keys.markus keys.bu-ki ];
  "m365_competences_3a.config".publicKeys = [ keys.markus keys.bu-ki ];
  "m365_competences_3c.config".publicKeys = [ keys.markus keys.bu-ki ];
  "m365_competences_4d.config".publicKeys = [ keys.markus keys.bu-ki ];
  "m365_competences_5b.config".publicKeys = [ keys.markus keys.bu-ki ];
  "m365_competences_6b.config".publicKeys = [ keys.markus keys.bu-ki ];
  "users/markus".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/marion".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.mnb ];
  "users/raphaela".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/gabriel".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "spotify".publicKeys = [ keys.markus keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "bu-ki/marmay-auth-security-config".publicKeys = [ keys.markus keys.bu-ki ];
  "bu-ki/bghorn-cms-security-config".publicKeys = [ keys.markus keys.bu-ki ];
  "bu-ki/bghorn-cms-publisher-ftp-password".publicKeys = [ keys.markus keys.bu-ki ];
  "bu-ki/competences-m2a-security-config".publicKeys = [ keys.markus keys.bu-ki ];
}