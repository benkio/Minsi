# Minsi Backend

PureScript Express server for Minsi web app

## Dependencies

- `purescript` - PureScript compiler
- `spago` - PureScript package manager
- `express` - Node.js Express framework (npm package)
- `purescript-express` - PureScript bindings for Express

## Setup

1. Install PureScript and Spago if you haven't already:

   ```bash
   npm install -g purescript spago
   ```

2. Install npm dependencies:

   ```bash
   cd backend
   npm install
   ```

3. Install PureScript dependencies:
   ```bash
   spago install
   ```

## Usage

### Development

1. **Compile the backend:**

   ```bash
   spago build
   ```

2. **Format**

   ```bash
   npx purs-tidy format-in-place "src/**/*.purs" && npx purs-tidy format-in-place "test/**/*.purs"
   ```

3. **Run the server:**

   ```bash
   spago run
   ```

4. **Access the application:**
   - The server will start on `http://localhost:8080`
   - It serves all static files from the `../public/` folder
   - The root route (`/`) serves `index.html`
   - Other files (like `index.js`) are served at their respective paths

### Production

The server uses Express static middleware to serve all files from the `public/` directory. Make sure the frontend is bundled and placed in the `public/` folder before starting the server. Then exposes routes for the Minsi Web App

## Configuration

The server is configured to:

- Listen on port `8080`
- Serve static files from `../public/` (relative to the backend directory)
- Use Express static middleware for file serving
