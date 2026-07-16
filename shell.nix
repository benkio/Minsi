# Development shell for frontend + backend.
# Enter with: nix-shell
#
# PureScript toolchain comes from purescript-overlay (nixpkgs only ships
# spago-legacy). System tools match Dockerfile / README runtime deps.
{
  pkgs ? import <nixpkgs> {
    config.allowUnfree = true; # corefonts (Impact, Arial Black for subtitles)
    overlays = [
      (import (
        builtins.fetchTarball {
          url = "https://github.com/thomashoneyman/purescript-overlay/archive/main.tar.gz";
        }
      )).overlays.default
    ];
  },
}:

pkgs.mkShell {
  name = "minsi";

  packages = with pkgs; [
    # Build / toolchain (Dockerfile builder + CI)
    nodejs_24
    purs
    spago-unstable
    purs-tidy
    esbuild
    git
    curl
    cacert

    # Runtime media pipeline (Dockerfile runtime + SoftwareCheck)
    ffmpeg
    yt-dlp
    id3v2
    fontconfig
    corefonts
  ];

  # Make Impact / Arial Black visible to fc-list (subtitle GIF path)
  FONTCONFIG_FILE = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.corefonts ];
  };

  shellHook = ''
    echo "minsi nix-shell: node $(node -v), purs $(purs --version), spago $(spago --version)"
    echo "Runtime tools: ffmpeg, yt-dlp, id3v2, fc-list"
    echo "Next: npm ci --prefix backend && (cd frontend && spago build) && (cd backend && spago build)"
  '';
}
