# Remote desktop connections for the xmonad session: agenix-encrypted
# connection files, a rofi launcher, and the tooling to edit the secrets.
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.marmar.xmonad;
  rcfg = cfg.remote;

  connections = import ../../../secrets/remote/connections.nix;
  remoteNames =
    map (n: "rdp-${n}") connections.rdp
    ++ map (n: "vnc-${n}") connections.vnc;

  # Defaults for every RDP session; the per-connection file comes last and
  # may override any of them.
  rdpDefaults = [
    "/dynamic-resolution"      # server resolution follows the window size
    "+auto-reconnect"
    "/cert:tofu"               # trust a server certificate on first use
    "/sound:sys:pulse"
    "/microphone:sys:pulse"
    "+clipboard"
    "/kbd:layout:${rcfg.keyboardLayout}"
    "-grab-keyboard"           # xmonad keeps its bindings; see the passthrough toggle
  ] ++ lib.optional (rcfg.scale != null) "/scale:${toString rcfg.scale}";

  remoteMenu = pkgs.writeShellApplication {
    name = "xmonad-remote";
    runtimeInputs = with pkgs; [ rofi freerdp tigervnc wmctrl libnotify coreutils gawk pass ];
    text = ''
      secrets="''${XMONAD_REMOTE_DIR:-${config.age.secretsDir}}"
      state="''${XDG_RUNTIME_DIR:-/tmp}/xmonad-remote"
      mkdir -p "$state"
      chmod 700 "$state"

      # The secrets directory is not listable (0751), so the names are baked
      # in from connections.nix and each file is probed by its exact path.
      names=()
      for n in ${lib.escapeShellArgs remoteNames}; do
        if [ -r "$secrets/remote-$n" ]; then
          names+=("$n")
        fi
      done
      if [ "''${#names[@]}" -eq 0 ]; then
        notify-send -a xmonad -u critical "Keine Remote-Verbindungen eingerichtet"
        exit 1
      fi

      choice=$(printf '%s\n' "''${names[@]}" | rofi -dmenu -i -p "Remote")
      [ -n "$choice" ] || exit 0
      secret="$secrets/remote-$choice"
      pidfile="$state/$choice.pid"

      # Already running? Bring its window to the front instead of starting
      # a second session. wmctrl lists managed windows with their PID.
      if [ -r "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        pid=$(cat "$pidfile")
        win=$(wmctrl -lp | awk -v p="$pid" '$3 == p { print $1; exit }')
        if [ -n "$win" ]; then
          wmctrl -i -a "$win"
        else
          notify-send -a xmonad "$choice läuft bereits"
        fi
        exit 0
      fi

      # The password lives in pass only; it is fetched now and handed to the
      # client through a pipe, so it is never on disk or in the process list.
      entry="${rcfg.passPrefix}/$choice"
      if ! password=$(pass show "$entry" | head -n1); then
        notify-send -a xmonad -u critical "Kein Passwort in pass: $entry"
        exit 1
      fi

      # The client replaces this script, so its PID is ours.
      echo $$ > "$pidfile"
      case "$choice" in
        rdp-*)
          exec xfreerdp /args-from:stdin < <(
            printf '%s\n' ${lib.escapeShellArgs rdpDefaults} "/t:$choice"
            cat "$secret"
            printf '/p:%s\n' "$password"
          )
          ;;
        vnc-*)
          mapfile -t lines < "$secret"
          passfile="$state/$choice.passwd"
          (umask 077; printf '%s\n' "$password" | vncpasswd -f > "$passfile")
          exec vncviewer -passwd "$passfile" "''${lines[@]:1}" "''${lines[0]}"
          ;;
        *)
          notify-send -a xmonad -u critical "Unbekannter Verbindungstyp: $choice"
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.marmar.xmonad.remote = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "markus";
      description = "User that may read the decrypted connection files.";
    };

    scale = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ 100 140 180 ]);
      default = null;
      example = 180;
      description = "FreeRDP display scaling for HiDPI screens (/scale).";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "0x407";
      description = "Windows keyboard layout id passed to FreeRDP (0x407 = German).";
    };

    passPrefix = lib.mkOption {
      type = lib.types.str;
      default = "remote";
      description = "Folder in the pass store holding one entry per connection, e.g. remote/rdp-dc01.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = lib.listToAttrs (map (n: {
      name = "remote-${n}";
      value = {
        file = ../../../secrets/remote + "/${n}.age";
        owner = rcfg.user;
        mode = "0400";
      };
    }) remoteNames);

    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    services.xserver.windowManager.xmonad.xmonadCliArgs = [
      "--remote-menu=${lib.getExe remoteMenu}"
    ];
  };
}
