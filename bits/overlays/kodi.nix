self: super: {
  kodi = super.kodi.override {
    libbluray = super.libbluray.override {
      withAACS = true;
      withBDplus = true;
    };
  };
}


