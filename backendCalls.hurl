# Backend API Calls
# Server runs on http://localhost:8080

# Verifies that required software and fonts are available
# @name checkDependencies
POST http://localhost:8080/checkDependencies
Content-Type: application/json

###

# Verifies that required software and fonts are available
# @name status
POST http://localhost:8080/status
Content-Type: application/json

{ "filename": "test.mp4" }

###

# Processes video cutting request
# @name compute
POST http://localhost:8080/compute
Content-Type: application/json

{
  "cutVideo": {
    "start": 0.0,
    "end": 100.0
  },
  "youtubeUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "filename": "output.mp4",
  "reverseLoop": false,
  "artist": "Test Artist",
  "title": "Test Title",
  "subtitles": [
    {
      "videoPosition": {
        "start": 10.0,
        "end": 20.0
      },
      "value": "Test subtitle",
      "font": "Impact",
      "fontSize": 24,
      "color": "#ffffff",
      "screenPosition": "Top"
    },
    {
      "videoPosition": {
        "start": 30.0,
        "end": 40.0
      },
      "value": "Another subtitle",
      "font": "Arial Black",
      "fontSize": 32,
      "color": "#FFFF00",
      "screenPosition": "Bottom"
    }
  ]
}

# ###
