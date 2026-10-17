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
    cacert
    curl
    esbuild
    git
    nodejs_24
    purs
    purs-tidy
    spago-unstable

    # Runtime media pipeline (Dockerfile runtime + SoftwareCheck)
    ffmpeg
    yt-dlp
    id3v2
    fontconfig
    corefonts

    # Local punctuation-restoration service (non-Docker dev)
    # `punctuators` is installed from requirements.txt inside a venv.
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.fastapi
    python3Packages.uvicorn
  ];

  # Make Impact / Arial Black visible to fc-list (subtitle GIF path)
  FONTCONFIG_FILE = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.corefonts ];
  };

  shellHook = ''
    PUNCT_DIR="$PWD/punctuation-service"
    PUNCT_VENV="$PUNCT_DIR/.venv"
    PUNCT_PY="$PUNCT_VENV/bin/python"
    PUNCT_PIP="$PUNCT_VENV/bin/pip"

    if [ -f "$PUNCT_DIR/requirements.txt" ]; then
      if [ ! -x "$PUNCT_PY" ]; then
        echo "Setting up punctuation-service virtualenv..."
        python3 -m venv "$PUNCT_VENV"
      fi

      if ! "$PUNCT_PY" -c "import punctuators" >/dev/null 2>&1; then
        echo "Installing punctuation-service Python requirements..."
        PIP_DISABLE_PIP_VERSION_CHECK=1 "$PUNCT_PIP" install -r "$PUNCT_DIR/requirements.txt"
      fi
    fi

    echo "minsi nix-shell: node $(node -v), purs $(purs --version), spago $(spago --version)"
    echo "Python: $(python3 --version)"
    echo "Runtime tools: ffmpeg, yt-dlp, id3v2, fc-list"
    echo "Next: npm ci --prefix backend && (cd frontend && spago build) && (cd backend && spago build)"
    echo "Punctuation service python: $PUNCT_PY"
  '';
}
