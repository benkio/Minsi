# Use linux/amd64 so npm install -g purescript gets a prebuilt binary (linux-aarch64 often 403)
# Stage 1: build frontend and backend
FROM node:24-bookworm-slim AS builder

WORKDIR /usr/src/minsi

# Install only build deps (no ffmpeg/yt-dlp needed for build)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g spago@next purescript esbuild

# Copy package files first for better layer caching
COPY backend/package.json backend/package-lock.json* backend/
COPY frontend/spago.yaml frontend/spago.lock* frontend/

# Copy full source
COPY . .

# Bundle frontend
WORKDIR /usr/src/minsi/frontend
RUN spago build && \
    spago bundle -p minsi-frontend --platform browser --source-maps --minify --outfile=../public/index.js

# Build backend
WORKDIR /usr/src/minsi/backend
RUN npm ci && spago build

# Stage 2: minimal runtime image
FROM node:24-bookworm-slim

WORKDIR /usr/src/minsi

# Runtime system deps; use latest yt-dlp + latest shared FFmpeg build.
# Shared FFmpeg avoids DNS issues seen with fully static binaries in containers.
RUN echo "deb http://deb.debian.org/debian/ bookworm main contrib" > /etc/apt/sources.list.d/bookworm.list && \
    echo "deb http://security.debian.org/ bookworm-security main contrib" >> /etc/apt/sources.list.d/bookworm.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    libc6 \
    ttf-mscorefonts-installer \
    fontconfig \
    id3v2 \
    curl \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH

# Latest shared FFmpeg release (BtbN)
RUN case "${TARGETARCH}" in \
      amd64) FFMPEG_ARCH="linux64" ;; \
      arm64) FFMPEG_ARCH="linuxarm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
      "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-${FFMPEG_ARCH}-gpl-shared.tar.xz" \
      -o /tmp/ffmpeg.tar.xz \
    && mkdir -p /opt/ffmpeg \
    && tar -xJf /tmp/ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
    && ln -sf /opt/ffmpeg/bin/ffmpeg /usr/local/bin/ffmpeg \
    && ln -sf /opt/ffmpeg/bin/ffprobe /usr/local/bin/ffprobe \
    && rm -f /tmp/ffmpeg.tar.xz

# Latest yt-dlp release
RUN case "${TARGETARCH}" in \
      amd64) YTDLP_ARCH="" ;; \
      arm64) YTDLP_ARCH="_aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
      "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${YTDLP_ARCH}" \
      -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp

ENV LD_LIBRARY_PATH=/opt/ffmpeg/lib

RUN ffmpeg -version
RUN ffprobe -version
RUN yt-dlp --version

# Copy built app from builder (no spago/purescript/esbuild, no frontend src)
COPY --from=builder /usr/src/minsi/public ./public
COPY --from=builder /usr/src/minsi/backend/output ./backend/output
COPY --from=builder /usr/src/minsi/backend/run.js ./backend/
COPY --from=builder /usr/src/minsi/backend/package.json ./backend/
COPY --from=builder /usr/src/minsi/backend/package-lock.json* ./backend/
COPY --from=builder /usr/src/minsi/backend/node_modules ./backend/node_modules

WORKDIR /usr/src/minsi/backend

EXPOSE 8080
CMD ["node", "run.js"]
