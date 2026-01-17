# Backend API Calls
# Server runs on http://localhost:8080

# Check Dependencies Endpoint
# Verifies that required software and fonts are available
POST http://localhost:8080/checkDependencies
Content-Type: application/json

###

# Cut Video Endpoint
# Processes video cutting request
POST http://localhost:8080/cutVideo
Content-Type: application/json

{
  "cutVideo": {
    "start": 0.0,
    "end": 100.0
  },
  "youtubeUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "filename": "output.mp4",
  "reverseLoop": false,
  "artist": "Artist Name",
  "title": "Video Title",
  "subtitles": []
}

###
