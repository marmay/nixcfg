self: super: {
  tvheadend = super.tvheadend.overrideAttrs (oldAttrs: rec {
      version = "20220209-master";
      src = super.pkgs.fetchFromGitHub {
        owner = "tvheadend";
        repo = "tvheadend";
        rev = "c7b713edb0ae4fee6acbd65c27017cb01c12348a";
        sha256 = "sha256:15f461a6z5rngg2fi5h3lbdkh6pqvccyljph4545gpdsfk902iwy";
      };
      configureFlags = oldAttrs.configureFlags ++ [ "--disable-tvhcsa" ];
      buildInputs = oldAttrs.buildInputs ++ [ self.x264 self.x265 self.libvpx self.libopus ];
  });
}
