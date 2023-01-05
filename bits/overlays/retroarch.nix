self: super: {
  retroarch = super.retroarch.override {
    cores = [ super.libretro-snes9x ];
  };
}
