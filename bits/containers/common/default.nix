let dataPath = "/srv/media";
    serviceBase = "${dataPath}/Services";
in
{
  containerNetwork = {
    privateNetwork = true;
    hostBridge = "br0";
  };

  path = {
    data = "${dataPath}";

    music = "${dataPath}/Musik";
    videos = "${dataPath}/Videos";

    serviceBase = "${serviceBase}";

    mkServicePathActivations =
      let mkActivation = p : ''
          if [ ! -d "${serviceBase}/${p.host}" ]; then
            mkdir -p "${serviceBase}/${p.host}";
          fi;
          chmod 777 ${serviceBase}/${p.host};
        '';
      in ps : {
        text = (builtins.concatStringsSep "\n" (map mkActivation ps));
        deps = [];
      };

    mkServicePathBinds =
      let mkActivation = p : { "${p.container}" = { hostPath = "${serviceBase}/${p.host}"; isReadOnly = false; }; };
      in ps : map mkActivation ps;
  };
}
