const backgroundSound = new Audio("loadingSound.mp3");

function startAudio(audio) {
  console.log("[Modal.js] Starting audio: " + audio.src);
  try {
    audio.play();
  } catch (err) {
    console.log("[Modal.js] Error playing the audio: " + JSON.stringify(err));
  }
}

function stopBackground(audio) {
  console.log("[Modal.js] Stopping audio: " + audio.src);
  try {
    audio.pause();
    audio.currentTime = 0;
  } catch (err) {
    console.log("[Modal.js] Error stopping the audio: " + JSON.stringify(err));
  }
}

export function showModal(id) {
  return function (maybeTimeout) {
    return function () {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      startAudio(backgroundSound);
      el.addEventListener("hidden.bs.modal", () => {
        console.log("[Modal.js] Modal closed " + id);
        stopBackground(backgroundSound);
      });
      console.log(
        `[Modal.js] Setting Timeout: ${JSON.stringify(maybeTimeout)}`,
      );
      if (maybeTimeout.tag === "Just") {
        setTimeout(() => {
          console.log(`Hiding the modal ${id}`);
          stopBackground(backgroundSound);
          modal.hide(id);
        }, maybeTimeout.value);
      }
    };
  };
}

export function hideModal(id) {
  return function () {
    stopBackground(backgroundSound);
    console.log("[Modal.js] Hide modal id: " + id);
    bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).hide();
  };
}
