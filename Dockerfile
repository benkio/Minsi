# Use linux/amd64 so npm install -g purescript gets a prebuilt binary (linux-aarch64 often 403)
FROM --platform=linux/amd64 node:latest

WORKDIR /usr/src/minsi

# Copy source over
COPY . .

# Install dependencies
RUN echo "deb http://deb.debian.org/debian/ bookworm main contrib" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian/ bookworm main contrib" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ bookworm-security main contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/ bookworm-security main contrib" >> /etc/apt/sources.list
RUN sed -i'.bak' 's/$/ contrib/' /etc/apt/sources.list

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y ffmpeg
RUN apt-get install -y yt-dlp
RUN apt-get install -y ttf-mscorefonts-installer
RUN apt-get install -y id3v2
RUN apt-get install -y curl
RUN npm install -g spago@next
RUN npm install -g purescript
RUN fc-cache -f

# Bundle frontend
WORKDIR /usr/src/minsi/frontend
RUN spago build
RUN spago bundle-app -t ../public/index.js

# Install/Build backend
WORKDIR /usr/src/minsi/backend
RUN npm install
RUN spago build

# Run server from backend directory
EXPOSE 8080
CMD ["spago", "run"]
