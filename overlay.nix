final: prev:

let
  sources = import ./sources.nix;

  mkKoreader = { pname, version, arm64, x86_64 }:
    { stdenvNoCC, fetchurl, p7zip }:
    let
      srcInfo = if stdenvNoCC.isAarch64 then arm64 else x86_64;
    in
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchurl { url = srcInfo.url; sha256 = srcInfo.sha256; };

      nativeBuildInputs = [ p7zip ];

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        mkdir -p "$out/Applications" "$out/bin"

        7z x "$src" -o"$out/Applications"

        printf '#!/bin/sh\nexec "$(dirname "$0")/../Applications/KOReader.app/Contents/MacOS/koreader" "$@"\n' \
          > "$out/bin/koreader"
        chmod +x "$out/bin/koreader"
      '';

      meta = with prev.lib; {
        description = "Document viewer for PDF, EPUB, DJVU, FB2, CBZ (macOS)";
        homepage = "https://koreader.rocks";
        license = licenses.agpl3Only;
        platforms = [ "aarch64-darwin" "x86_64-darwin" ];
        mainProgram = "koreader";
        longDescription = ''
          KOReader is a document viewer originally designed for E Ink readers.
          Supports PDF, EPUB, DJVU, MOBI, CBZ, FB2, and more.

          ⚠️  This is an unsigned CI artifact mirrored from koreader/koreader.
          Right-click → Open the app to bypass Gatekeeper on first launch.
        '';
      };
    };
in
{
  koreader = prev.callPackage
    (mkKoreader {
      pname = "koreader";
      inherit (sources.koreader) version arm64 x86_64;
    })
    { };

  koreader-nightly = prev.callPackage
    (mkKoreader {
      pname = "koreader-nightly";
      version = "nightly";
      inherit (sources.koreader-nightly) arm64 x86_64;
    })
    { };
}
