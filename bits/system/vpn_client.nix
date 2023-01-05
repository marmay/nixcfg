{ lib, pkgs, config, ... }:
{
  options = {
    openvpnCfg.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enables primary vpn connection.";
    };
    openvpnCfg.clientCert = lib.mkOption {
      type = lib.types.path;
      description = "File containing client cert.";
    };
    openvpnCfg.clientKey = lib.mkOption {
      type = lib.types.path;
      description = "File containing client key.";
    };
    openvpnCfg.serverCert = lib.mkOption {
      type = lib.types.path;
      description = "File containing public server cert.";
    };
    openvpnCfg.taKey = lib.mkOption {
      type = lib.types.path;
      description = "File containing tls-auth key.";
    };
    openvpnCfg.host = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host to connect to.";
    };
    openvpnCfg.port = lib.mkOption {
      default = 1194;
      type = lib.types.port;
      description = "Port to connect to.";
    };
    openvpnCfg.autoStart = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Whether to automatically start the VPN connection.";
    };
  };

  config = lib.mkIf config.openvpnCfg.enable {
    services.openvpn.servers."${config.openvpnCfg.host}:${builtins.toString config.openvpnCfg.port}" = {
      autoStart = config.openvpnCfg.autoStart;
      config = ''
        client
        dev tun
        proto udp
        remote ${config.openvpnCfg.host} ${builtins.toString config.openvpnCfg.port}
        nobind
        user nobody
        group nogroup
        persist-key
        persist-tun
        remote-cert-tls server
        auth SHA256
        verb 3
        ca ${config.openvpnCfg.serverCert}
        cert ${config.openvpnCfg.clientCert}
        key ${config.openvpnCfg.clientKey}
        tls-auth ${config.openvpnCfg.taKey}
      '';
    };
  };
}
