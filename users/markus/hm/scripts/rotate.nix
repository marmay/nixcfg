{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "rotate" ''
#!/bin/sh

echo "Rotating; first arg: $1"

case "$1" in
  0)
    ROTATE_XRANDR=normal
    ROTATE_XSETWACOM=none
    ;;
  90)
    ROTATE_XRANDR=left
    ROTATE_XSETWACOM=ccw
    ;;
  180)
    ROTATE_XRANDR=inverted
    ROTATE_XSETWACOM=half
    ;;
  270)
    ROTATE_XRANDR=right
    ROTATE_XSETWACOM=cw
    ;;
  *)
    echo "Please provide an argument: 0, 90, 180 or 270."
    exit 1
    ;;
esac

xrandr --output eDP-1 --rotate $ROTATE_XRANDR
for device in 11 12 17; do
  xsetwacom set $device rotate $ROTATE_XSETWACOM;
done
    '')

    (writeShellScriptBin "projector" ''
#!/bin/sh

case "$1" in
  lowres)
    xrandr --output eDP-1 --mode 1280x720 --output HDMI-1 --mode 1280x720 --same-as eDP-1
    ;;
  highres)
    xrandr --output eDP-1 --mode 1920x1200
    ;;
  *)
    xrandr --output eDP-1 --mode 1920x1200
    ;;
esac
    '')
  ];
}