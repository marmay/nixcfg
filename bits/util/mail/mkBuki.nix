{ realName, address }: {
  realName = realName;
  address = address;
  userName = address;
  imap = {
    host = "mail.bu-ki.at";
    port = 143;
    tls = {
      enable = true;
      useStartTls = true;
    };
  };
  smtp = {
    host = "mail.bu-ki.at";
    port = 587;
    tls = {
      enable = true;
      useStartTls = true;
    };
  };
} // (import ./mailClients.nix {})
