# Remote desktop connections. Each name corresponds to an encrypted file in
# this directory: rdp-<name>.age or vnc-<name>.age (see README.md). The list is
# read by secrets.nix (encryption rules) and by bits/system/xmonad/remote.nix
# (decryption on the hosts), so adding a connection is one entry here plus
# one `agenix -e` invocation.
{
  rdp = [ "dc01" "dc02" ];
  vnc = [ ];
}
