{ actkbd, makeWrapper }:

actkbd.overrideAttrs (oldAttrs: {
  nativeBuildInputs = [ makeWrapper ];
  patches = [ ./actkbd-daemon-noclose.patch ];
  # Be carefull here not to enable full keyboard logging (security)
  postInstall = oldAttrs.postInstall + ''
    wrapProgram $out/sbin/actkbd --add-flags "-v2 -x"
  '';
})

