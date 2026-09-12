{
  pkgs,
  system ? pkgs.stdenv.hostPlatform.system,
  ...
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  # widevine-cdm is unfree; pull it from a nixpkgs instance that permits just
  # that package so consumers don't have to set allowUnfree themselves.
  pkgsWidevine =
    if (pkgs.config.allowUnfree or false) then
      pkgs
    else
      import pkgs.path {
        inherit system;
        config = pkgs.config // {
          allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "widevine-cdm";
        };
      };
in
rec {
  zen-browser-unwrapped = pkgs.callPackage ./zen-browser-unwrapped.nix {
    inherit (sources.${system}) hash url;
    inherit (sources) version;
  };
  zen-browser = pkgs.callPackage ./zen-browser.nix {
    inherit zen-browser-unwrapped;
    inherit (pkgsWidevine) widevine-cdm;
  };
  zen-browser-generic = builtins.trace "WARNING: Zen upstream no longer differentiates between specific and generic builds, this package is kept for flake backwards-compatibility only. Please use the default `zen-browser` package instead." zen-browser;
  default = zen-browser;
}
