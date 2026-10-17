from __future__ import annotations

import inspect
import os
from dataclasses import dataclass

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from punctuators.models import PunctCapSegModelONNX


MODEL_ID = "1-800-BAD-CODE/xlm-roberta_punctuation_fullstop_truecase"


def _read_bool_env(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


@dataclass(frozen=True)
class ServiceConfig:
    local_files_only: bool


class RestoreRequest(BaseModel):
    text: str = Field(min_length=1, max_length=120000)


class RestoreResponse(BaseModel):
    text: str


class ErrorResponse(BaseModel):
    error: str


config = ServiceConfig(
    local_files_only=_read_bool_env("MINSI_PUNCTUATION_LOCAL_FILES_ONLY", False)
)

def _load_model() -> PunctCapSegModelONNX:
    # Older punctuators versions don't expose `local_files_only` on from_pretrained.
    # In that case we still support offline behavior via HF_HUB_OFFLINE=1.
    if config.local_files_only:
        os.environ["HF_HUB_OFFLINE"] = "1"

    from_pretrained = PunctCapSegModelONNX.from_pretrained
    params = inspect.signature(from_pretrained).parameters
    if "local_files_only" in params:
        return from_pretrained(MODEL_ID, local_files_only=config.local_files_only)
    return from_pretrained(MODEL_ID)


# Loaded once at startup and reused for all requests.
model = _load_model()

app = FastAPI(title="Minsi punctuation restoration")


@app.get("/health")
def health() -> dict[str, str]:
    mode = "offline-cache-only" if config.local_files_only else "online-or-cache"
    return {"status": "ok", "model": MODEL_ID, "mode": mode}


@app.post(
    "/restore",
    response_model=RestoreResponse,
    responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}},
)
def restore(body: RestoreRequest) -> RestoreResponse:
    text = body.text.strip()
    if text == "":
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    try:
        restored_batch = model.infer([text], apply_sbd=False)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"Restoration inference failed: {type(exc).__name__}") from exc

    if not restored_batch or not isinstance(restored_batch[0], str):
        raise HTTPException(status_code=500, detail="Restoration service returned an unexpected output shape.")

    return RestoreResponse(text=restored_batch[0])
