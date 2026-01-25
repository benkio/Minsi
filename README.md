# Minsi

Opinionated YouTube Clip Video GIF Audio Extractor

A web application for downloading YouTube videos and creating customized clips with subtitles, GIFs, and audio extracts.

## Project Structure

- **[Frontend](./frontend/README.md)** - PureScript frontend application
- **[Backend](./backend/README.md)** - PureScript Express server

## Dependencies

The following system dependencies are required for video processing:

- `ffmpeg` - Video/audio processing and conversion
- `yt-dlp` - YouTube video downloading
- `id3v2` - MP3 metadata tagging
- `fc-list` - Font listing utility
- [Impact font](https://www.dafontfree.io/download/impact/) - Subtitle font
- [Arial Black font](https://online-fonts.com/fonts/arial-black) - Subtitle font

## Usage

1. **Start the backend server:**
   ```bash
   cd backend
   spago build
   spago run
   ```

2. **Build the frontend:**
   ```bash
   cd frontend
   spago build
   spago bundle-app -t ../public/index.js
   ```

3. **Open the application:**
   - Navigate to `http://localhost:8080` in your browser
   - The server will serve the frontend from the `public/` folder
   - The files will be stored in the `/output` folder

## Motivation

I needed a tool to download and create, from a YouTube Clip/video, the:
- GIF with specific subtitles
- MP3 audio extract
- Video clip

With the best possible quality. Therefore, I created [this
script](https://gist.github.com/benkio/103960b7b5a5781c222df1c4e31544a2)
that does exactly that.

The only problem is its usability.
Here, I want to extend that giving a UI, so it's more user friendly.
