final: prev: {
 xsecurelock = prev.xsecurelock.overrideAttrs (oldAttrs: {
   configureFlags = [
     "--with-pam-service-name=xscreensaver"
     "--with-xscreensaver=${final.xscreensaver}/bin/xscreensaver"
   ];
 });
}