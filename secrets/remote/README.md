# Remote desktop connections

Each connection is an agenix-encrypted file with host, user and options (no
password) in this directory, decrypted at
boot to `/run/agenix/remote-<type>-<name>` (owner: the desktop user, mode 0400).
The launcher `xmonad-remote` (bound to `M-S-v`) lists these names in rofi.

## Adding a connection

1. Add the name to `connections.nix` under `rdp` or `vnc`.
2. From the `secrets/` directory run `agenix -e remote/rdp-<name>.age`
   (or `vnc-<name>.age`) and paste the content described below.
3. Rebuild. The file appears under `/run/agenix/` after activation.

Re-keying after adding a host key: `agenix -r` in `secrets/`.

## rdp-<name>.age

One FreeRDP argument per line, no comments, no blank lines. Everything the
launcher passes by default (dynamic resolution, auto-reconnect, sound,
clipboard, keyboard layout, ...) can be overridden here, later lines win.
No `/p:` line: the password comes from pass (see below).

    /v:host.example.org
    /u:username
    /d:DOMAIN

Useful extras: `/gfx:AVC444` (H.264, if the server supports it), `/f`
(start fullscreen), `/drive:home,/home/markus` (share a directory),
`/port:3390`, `/gateway:...`.

## vnc-<name>.age

Line 1: target (`host`, `host:display` or `host::port`). Further lines: extra
`vncviewer` arguments. The password comes from pass.

    host.example.org::5900
    -RemoteResize

## Passwords

Passwords are not stored in these files. The launcher runs
`pass show remote/<type>-<name>` (folder configurable via
`marmar.xmonad.remote.passPrefix`) and uses the first line, so create one
entry per connection, e.g. `pass insert remote/rdp-dc01`.
