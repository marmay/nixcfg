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
  "aws/host".publicKeys = [ keys.markus keys.aws ];
  "aws/ama".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/ase".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/afe".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/aro".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/fmi".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/hcl".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/mma".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/mev".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/psa".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/pma".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/psi".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/pst".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/rel".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/ran".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/sla".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/sdo".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/tha".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/ula".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/vel".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/vlo".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/wma".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
  "aws/zto".publicKeys = [ keys.markus keys.bu-ki keys.aws ];
}