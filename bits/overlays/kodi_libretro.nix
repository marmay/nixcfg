self: super: {
  kodiPkgs.libretro-parallel-n64 = {
    libretro-parallel-n64 =
      super.callPackage ../customPackages/applications/video/kodi/addons/libretro-parallel-n64 { buildKodiBinaryAddon = super.kodiPkgs.buildKodiBinaryAddon; };
  };
}
