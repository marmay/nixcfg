# agenix rules: which keys may decrypt which file. Run agenix from this
# directory (it reads ./secrets.nix), e.g. `agenix -e remote/rdp-work.age`.
let
  # Your user key, used for editing.
  markus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEephuB9vIL03T+9Yq9tYjjr/HBoWgDDCp1utrp6KhvH";

  # Host keys (cat /etc/ssh/ssh_host_ed25519_key.pub on each host), used for
  # decryption at activation.
  mnb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqIn8mpjv2VbwSe0aCcsPPt5Ddjibzi2VMGHXFsEdPq";
  # keller = "ssh-ed25519 ...";
  hosts = [ mnb ];

  connections = import ./remote/connections.nix;
  remoteNames =
    map (n: "rdp-${n}") connections.rdp
    ++ map (n: "vnc-${n}") connections.vnc;
in
builtins.listToAttrs (map (n: {
  name = "remote/${n}.age";
  value.publicKeys = [ markus ] ++ hosts;
}) remoteNames)
