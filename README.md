# koreader-macos

Mirror of [KOReader](https://github.com/koreader/koreader) macOS CI artifacts,
published as GitHub Releases with nix packages and a Homebrew tap.

KOReader does not publish macOS binaries in its releases — they only exist as
GitHub Actions CI artifacts (`.7z`).  This repo mirrors them into permanent
releases and provides both a Homebrew cask and nix flake for easy installation.

## How it works

```
koreader/koreader CI (macOS)         This repo
────────────────────────────        ──────────
  push to master ──────────────→    nightly cask + nix (every 6h)
  tag v2026.03   ──────────────→    tagged cask + nix (on release)
```

- **`watcher.yml`** — cron every 6 h, polls upstream releases, dispatches mirror.
- **`mirror.yml`** — downloads `.7z` from KOReader CI, creates/updates a GitHub Release here.
- **`update-sources.yml`** — updates `sources.nix`, `Casks/*.rb`, commits & pushes.

CI artifacts expire after 90 days on GitHub Actions.  This mirror preserves them
permanently in its own releases.

## Setup

1. Fork this repo.
2. Go to **Settings → Secrets and variables → Actions** and add a secret:

   | Name | Value |
   |------|-------|
   | `KOREADER_PAT` | Fine-grained PAT with **`actions: read`** on `koreader/koreader` |

3. Go to the **Actions** tab, select **Watch KOReader**, and run it once
   manually to seed the initial state.

The watcher will dispatch a nightly mirror immediately and, if a new upstream
tag is found, a tagged mirror too.  Tagged releases only trigger once per tag
(the cached `.latest-tag` file prevents re-processing).

## Homebrew

```
brew tap your-username/koreader-macos
brew install --cask koreader           # latest tagged release
brew install --cask koreader-nightly   # rolling CI build
```

Both casks strip the quarantine xattr automatically.  If Gatekeeper still
blocks the app, right-click → Open in Finder, or run:

```
sudo xattr -rd com.apple.quarantine /Applications/KOReader.app
```

## Nix

### Flake

```
nix build github:your-username/koreader-macos#koreader
nix build github:your-username/koreader-macos#koreader-nightly
nix run github:your-username/koreader-macos#koreader
```

### Overlay

```nix
# flake.nix
{
  inputs.koreader.url = "github:your-username/koreader-macos";
  outputs = { nixpkgs, koreader, ... }: {
    nixpkgs.overlays = [ koreader.overlays.default ];
  };
}
```

```nix
# Non-flake: /etc/nixpkgs/config.nix or ~/.config/nixpkgs/config.nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/your-username/koreader-macos/archive/main.tar.gz") + "/overlay.nix")
  ];
}
```

Then `nix-shell -p koreader` or `nix-shell -p koreader-nightly`.

### Default.nix

```
nix-build -A koreader
nix-build -A koreader-nightly
```

## Files

```
.
├── .github/workflows/
│   ├── watcher.yml           ← cron polling
│   ├── mirror.yml            ← download + release
│   └── update-sources.yml    ← nix & cask hashes
├── Casks/
│   ├── koreader.rb           ← stable cask
│   └── koreader-nightly.rb   ← nightly cask
├── overlay.nix               ← shared overlay (flake + non-flake)
├── sources.nix               ← URLs & hashes, auto-generated
├── default.nix               ← non-flake entry point
├── flake.nix                 ← minimal flake wrapper
└── flake.lock
```

## Limitations

- **Only macOS arm64 and x86_64** — KOReader's CI builds no other desktop platforms.
- **Tagged releases older than ~90 days** cannot be mirrored because GitHub
  Actions expires artifacts on that schedule.
- **App is unsigned and not notarized** — you must bypass Gatekeeper on first
  launch.  The casks handle this in `postflight`.
