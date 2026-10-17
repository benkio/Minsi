# Local punctuation restoration service

This service runs locally and restores punctuation/capitalization using:

`1-800-BAD-CODE/xlm-roberta_punctuation_fullstop_truecase`

It is designed to be called by the Minsi backend (`POST /transcript` and transcription pipeline integration).

## Requirements

- Python 3.10+
- Internet access only for the first model download (unless model cache is pre-populated)

## Install

```bash
cd punctuation-service
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run

```bash
uvicorn app:app --host 127.0.0.1 --port 8090
```

The backend default expects `http://127.0.0.1:8090/restore`.

## Offline mode after first download

After the first successful run (model cached), force cache-only mode:

```bash
MINSI_PUNCTUATION_LOCAL_FILES_ONLY=true uvicorn app:app --host 127.0.0.1 --port 8090
```

If cache-only mode is enabled and the model is not in cache, startup fails.

## Backend integration env var

You can override the backend service URL:

```bash
MINSI_PUNCTUATION_SERVICE_URL=http://127.0.0.1:8090/restore
```

## Troubleshooting

- `Restoration failed (connection refused)`: start the service, then retry compute.
- Slow first request/startup: first model download is in progress.
- `local_files_only` startup failure: run once without `MINSI_PUNCTUATION_LOCAL_FILES_ONLY=true` to warm the cache.
