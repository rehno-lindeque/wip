final: prev:
prev.lib.optionalAttrs (prev.stdenv.hostPlatform.isLinux && prev.stdenv.hostPlatform.isAarch64) {
  widevine-firefox = final.callPackage ../packages/widevine-firefox {};

  brave-widevine = prev.brave.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      ln -sfn ${final.widevine-cdm}/share/google/chrome/WidevineCdm \
        $out/opt/brave.com/brave/WidevineCdm
    '';
  });

  firefox-widevine = prev.firefox.override (old: {
    extraPrefs = (old.extraPrefs or "") + ''
      pref("media.gmp-widevinecdm.version", "system-installed");
      pref("media.gmp-widevinecdm.visible", true);
      pref("media.gmp-widevinecdm.enabled", true);
      pref("media.gmp-widevinecdm.autoupdate", false);
      pref("media.eme.enabled", true);
      pref("media.eme.encrypted-media-encryption-scheme.enabled", true);
    '';
  });
}
