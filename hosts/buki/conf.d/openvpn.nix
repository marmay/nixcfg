let make_server_cfg =
  { host_ip ? "10.8.0.0", host_port ? 1194, caFile, dhFile, certFile, keyFile, taFile, clientConfigDirectory ? null }: ''
  port ${builtins.toString host_port}
  proto udp
  dev tun
  server ${host_ip} 255.255.255.0
  keepalive 10 120
  cipher AES-256-CBC
  auth SHA256
  user nobody
  group nogroup
  persist-key
  persist-tun
  verb 3
  explicit-exit-notify 1
  ${if clientConfigDirectory != null then "client-config-dir ${clientConfigDirectory}" else ""}
  ca ${caFile}
  dh ${dhFile}
  cert ${certFile}
  key ${keyFile}
  tls-auth ${taFile}
  '';
in { pkgs, config, ... }:
{
  config.agenix.secrets = {
    openvpnCa.file = ../../../secrets/markus/vpn/server/buki/ca.crt;
    openvpnCert.file = ../../../secrets/markus/vpn/server/cert;
    openvpnKey.file = ../../../secrets/markus/vpn/server/key;
    openvpnDh.file = ../../../secrets/markus/vpn/server/dh;
    openvpnTa.file = ../../../secrets/markus/vpn/server/ta.key;
  };

  config.services.openvpn.servers.bu_ki_at.config =
    make_server_cfg {
      caFile = config.agenix.secrets.openvpnCa.path;
      certFile = config.agenix.secrets.openvpnCert.path;
      keyFile = config.agenix.secrets.openvpnKey.path;
      dhFile = config.agenix.secrets.openvpnDh.path;
      taFile = config.agenix.secrets.openvpnTa.path;
      clientConfigDirectory = "/etc/openvpn/ccd";
    };
  config.environment.etc."openvpn/ccd/media.home".text = ''ifconfig-push 10.8.0.10 255.255.255.255 '';
  config.environment.etc."openvpn/ccd/ldap.home".text = ''ifconfig-push 10.8.0.20 255.255.255.255'';
}
