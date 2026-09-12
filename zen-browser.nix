{
  stdenv,
  wrapFirefox,
  ffmpeg_9,
  widevine-cdm,
  zen-browser-unwrapped,
  ...
}:
let
  widevineCdm = "${widevine-cdm}/share/google/chrome/WidevineCdm";
  widevinePlatform = if stdenv.hostPlatform.isAarch64 then "linux_arm64" else "linux_x64";
  wrapZen = wrapFirefox.override { ffmpeg_8 = ffmpeg_9; };
in
(wrapZen zen-browser-unwrapped {
  pname = "zen-browser";
  extraPrefs = ''
    lockPref("media.eme.enabled", true);
    lockPref("media.gmp-widevinecdm.enabled", true);
    lockPref("media.gmp-widevinecdm.visible", true);
    lockPref("media.gmp-widevinecdm.autoupdate", false);

    defaultPref("media.ffmpeg.vaapi.enabled", true);
    defaultPref("media.hardware-video-decoding.enabled", true);
    defaultPref("media.eme.video.prefer-platform-decoder", true);
  '';
}).overrideAttrs
  (old: {
    buildCommand = old.buildCommand + ''
      mkdir -p $out/gmp-widevinecdm/system-installed
      ln -s "${widevineCdm}/_platform_specific/${widevinePlatform}/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
      ln -s "${widevineCdm}/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
      wrapProgram "$out/bin/zen" \
        --set MOZ_GMP_PATH "$out/gmp-widevinecdm/system-installed"
    '';
  })
