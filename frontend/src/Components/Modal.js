const backgroundSound = new Audio("loadingSound.mp3");

function startAudio(audio) {
  console.log("Starting audio: " + audio.src);
  audio.play();
}

function stopBackground(audio) {
  console.log("Stopping audio: " + audio.src);
  audio.pause();
  audio.currentTime = 0;
}

export function showModal(id) {
  return function (maybeTimeout) {
    return function () {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      startAudio(backgroundSound);
      el.addEventListener("hidden.bs.modal", () => {
        console.log("Modal closed");
        stopBackground(backgroundSound);
      });
      console.log(`Setting Timeout: ${JSON.stringify(maybeTimeout)}`);
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
    const el = document.getElementById(id);
    const modal = bootstrap.Modal.getOrCreateInstance(el);
    stopBackground(backgroundSound);
    modal.hide();
  };
}
