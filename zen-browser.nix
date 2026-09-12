{
  stdenv,
  wrapFirefox,
  widevine-cdm,
  zen-browser-unwrapped,
  ...
}:
let
  widevineCdm = "${widevine-cdm}/share/google/chrome/WidevineCdm";
  widevinePlatform = if stdenv.hostPlatform.isAarch64 then "linux_arm64" else "linux_x64";
in
(wrapFirefox zen-browser-unwrapped {
  pname = "zen-browser";
}).overrideAttrs
  (old: {
    buildCommand = old.buildCommand + ''
      mkdir -p $out/gmp-widevinecdm/system-installed
      ln -s "${widevineCdm}/_platform_specific/${widevinePlatform}/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
      ln -s "${widevineCdm}/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
      wrapProgram "$oldExe" \
        --set MOZ_GMP_PATH "$out/gmp-widevinecdm/system-installed"
    '';
  })
