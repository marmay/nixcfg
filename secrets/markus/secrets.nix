let
  keys = import ../keys.nix;
in
{
  "vpn/client/ldap/cert".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/ldap/key".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/jellyfin/cert".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/jellyfin/key".publicKeys = [ keys.markus keys.nas ];
  "vpn/server/bu-ki/cert".publicKeys = [ keys.markus keys.nas keys.bu-ki ];
  "vpn/server/bu-ki/dh".publicKeys = [ keys.markus keys.bu-ki ];
  "vpn/server/bu-ki/key".publicKeys = [ keys.markus keys.bu-ki ];
  "vpn/server/bu-ki/ca.crt".publicKeys = [ keys.markus keys.nas keys.bu-ki ];
  "vpn/server/bu-ki/ta.key".publicKeys = [ keys.markus keys.nas keys.bu-ki ];
  "mail/hashed_pwd.gabriel".publicKeys = [ keys.markus keys.bu-ki ];
  "mail/hashed_pwd.marion".publicKeys = [ keys.markus keys.bu-ki ];
  "mail/hashed_pwd.markus".publicKeys = [ keys.markus keys.bu-ki ];
  "mail/hashed_pwd.raphaela".publicKeys = [ keys.markus keys.bu-ki ];
  "users/markus".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/marion".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.mnb ];
  "users/raphaela".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/gabriel".publicKeys = [ keys.markus keys.bu-ki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "spotify".publicKeys = [ keys.markus keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
}
