let
  keys = import ../keys.nix;
in
{
  "vpn/client/ldap/cert".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/ldap/key".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/jellyfin/cert".publicKeys = [ keys.markus keys.nas ];
  "vpn/client/jellyfin/key".publicKeys = [ keys.markus keys.nas ];
  "vpn/server/buki/cert".publicKeys = [ keys.markus keys.nas keys.buki ];
  "vpn/server/buki/dh".publicKeys = [ keys.markus keys.buki ];
  "vpn/server/buki/key".publicKeys = [ keys.markus keys.buki ];
  "vpn/server/buki/ca.crt".publicKeys = [ keys.markus keys.nas keys.buki ];
  "vpn/server/buki/ta.key".publicKeys = [ keys.markus keys.nas keys.buki ];
  "mail/hashed_pwd.gabriel".publicKeys = [ keys.markus keys.buki ];
  "mail/hashed_pwd.marion".publicKeys = [ keys.markus keys.buki ];
  "mail/hashed_pwd.markus".publicKeys = [ keys.markus keys.buki ];
  "mail/hashed_pwd.raphaela".publicKeys = [ keys.markus keys.buki ];
  "users/markus".publicKeys = [ keys.markus keys.buki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/marion".publicKeys = [ keys.markus keys.buki keys.nas keys.keller keys.notebook keys.mnb ];
  "users/raphaela".publicKeys = [ keys.markus keys.buki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "users/gabriel".publicKeys = [ keys.markus keys.buki keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
  "spotify".publicKeys = [ keys.markus keys.nas keys.keller keys.notebook keys.raphberry keys.mnb ];
}
