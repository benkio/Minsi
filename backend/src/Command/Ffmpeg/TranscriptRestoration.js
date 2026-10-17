export const _restoreTranscript = (serviceUrl) => (text) => (onSuccess) => (onError) => () => {
    fetch(serviceUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text }),
    })
        .then(async (response) => {
            const bodyText = await response.text();
            let payload = {};
            if (bodyText !== "") {
                try {
                    payload = JSON.parse(bodyText);
                } catch (_err) {
                    throw new Error(`[Transcription] Restoration service returned invalid JSON (${response.status}).`);
                }
            }
            if (!response.ok) {
                const details =
                    typeof payload.error === "string"
                        ? payload.error
                        : typeof payload.detail === "string"
                            ? payload.detail
                            : response.statusText;
                throw new Error(`[Transcription] Restoration failed (${response.status}): ${details}`);
            }
            if (typeof payload.text !== "string") {
                throw new Error("[Transcription] Restoration service response missing `text`.");
            }
            onSuccess(payload.text)();
        })
        .catch((err) => {
            const msg = err instanceof Error ? err.message : String(err);
            onError(msg)();
        });
};
