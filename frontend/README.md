# Minsi Frontend

PureScript frontend for the Minsi YouTube clip extractor. It provides the web UI (Bootstrap, YouTube embed) and talks to the backend API.

## Dependencies

- **PureScript** + **Spago** — build and package management

The backend must be running (see [root README](../README.md)) so the app can call its API and load/serve assets.

## Setup

1. Install PureScript and Spago (if needed):
   ```bash
   npm install -g purescript spago
   ```

2. From the **frontend** directory:
   ```bash
   spago install
   ```

## Usage

### Development

1. **Build:**
   ```bash
   spago build
   ```

2. **Bundle for the browser:**
   ```bash
   spago bundle -p minsi-frontend --platform browser --source-maps --minify --outfile=../public/index.js
   ```
   This writes the app bundle to **`public/index.js`**, which the backend serves.

3. **Tests:**
   ```bash
   spago test
   ```

4. **Format:**
   ```bash
   npm run format:purs
   ```

### Production

After bundling, open **http://localhost:8080** (with the backend running). The backend serves `index.html`, `index.js`, and other files from `public/`.
