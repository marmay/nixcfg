{ maxAge ? null, ... }:
{
  thunderbird = {
    enable = true;
    profiles = [ "default" ];
    settings =
      (if maxAge == null then (id: {}) else (id: {
        "mail.server.server_${id}.autosync_max_age_days" = maxAge;
      }));
  };
}
