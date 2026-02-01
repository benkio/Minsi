#!/usr/bin/env bash
# Bundle Minsi for Node: build frontend + backend, copy assets, bundle server.
# Run from the project root. Output is in dist/ (no PureScript needed to run it).

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "==> Creating dist/"
mkdir -p dist

echo "==> Building frontend"
cd frontend
spago build
spago bundle-app -t ../public/index.js
cd "$ROOT"

echo "==> Installing backend dependencies (npm install)"
cd backend
npm install
cd "$ROOT"

echo "==> Copying public/ and backend/node_modules/ to dist/"
cp -r public dist/
cp -r backend/node_modules dist/

echo "==> Building backend"
cd backend
spago build
cd "$ROOT"

echo "==> Bundling server (esbuild)"
npx esbuild backend/run.js --bundle --platform=node --outfile=dist/server.js --packages=external

echo "==> Patching server bundle to use ./public (for dist layout)"
sed 's|"\.\./public"|"./public"|g' dist/server.js > dist/server.js.tmp
mv dist/server.js.tmp dist/server.js

echo "==> Done. Run with: node dist/server.js (from project root or from dist/)"
