cask "koreader-nightly" do
  version :latest
  sha256 :no_check

  arch arm: "arm64", intel: "x86_64"

  url "https://github.com/proItheus/koreader-macos/releases/download/koreader-nightly/koreader-macos-#{arch}.7z",
      verified: "github.com/proItheus/"
  name "KOReader Nightly"
  desc "Document viewer for PDF, EPUB, DJVU, FB2, CBZ — bleeding-edge CI builds"
  homepage "https://koreader.rocks/"

  depends_on formula: "p7zip"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-d", "com.apple.quarantine", "#{appdir}/KOReader.app"],
                   sudo: false
  end

  app "KOReader.app"

  caveats <<~EOS
    This is an unsigned nightly CI artifact mirrored from koreader/koreader.
    Quarantine has been stripped automatically. If Gatekeeper still blocks it, run:
      sudo xattr -rd com.apple.quarantine /Applications/KOReader.app
  EOS
end
