# Minsi Frontend

PureScript frontend application for the Minsi YouTube clip extractor.

## Dependencies

- `purescript` - PureScript compiler
- `spago` - PureScript package manager

## Setup

1. Install PureScript and Spago if you haven't already:
   ```bash
   npm install -g purescript spago
   ```

2. Install project dependencies:
   ```bash
   cd frontend
   spago install
   ```

## Usage

### Development

1. **Compile the frontend:**
   ```bash
   spago build
   ```

2. **Bundle for browser:**
   ```bash
   spago bundle-app -t ../public/index.js
   ```

3. **Run tests:**
   ```bash
   spago test
   ```

### Production

After bundling, the `index.js` file will be placed in the `public/` folder at the root of the project. The backend server will serve this file along with the HTML.
