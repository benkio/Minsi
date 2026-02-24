# Use linux/amd64 so npm install -g purescript gets a prebuilt binary (linux-aarch64 often 403)
# Stage 1: build frontend and backend
FROM node:22-bookworm-slim AS builder

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
FROM node:22-bookworm-slim

WORKDIR /usr/src/minsi

# Runtime system deps; install latest yt-dlp from GitHub (Debian package is often outdated and breaks with YouTube)
RUN echo "deb http://deb.debian.org/debian/ bookworm main contrib" > /etc/apt/sources.list.d/bookworm.list && \
    echo "deb http://security.debian.org/ bookworm-security main contrib" >> /etc/apt/sources.list.d/bookworm.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    ttf-mscorefonts-installer \
    id3v2 \
    curl \
    ca-certificates \
    && curl -sSL -o /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
    && chmod +x /usr/local/bin/yt-dlp \
    && fc-cache -f \
    && rm -rf /var/lib/apt/lists/*

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
