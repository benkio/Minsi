const backgroundSound = new Audio("loadingSound.mp3");

function stopBackground() {
  backgroundSound.pause();
  backgroundSound.currentTime = 0;
}

export function showModal(id) {
  return function (maybeTimeout) {
    return function () {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      backgroundSound.play();
      el.addEventListener("hidden.bs.modal", () => {
        console.log("Modal closed - stopping background music");
        stopBackground();
      });
      console.log(`Setting Timeout: ${JSON.stringify(maybeTimeout)}`);
      if (maybeTimeout.tag === "Just") {
        setTimeout(() => {
          console.log(`Hiding the modal ${id}`);
          stopBackground();
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
    stopBackground();
    modal.hide();
  };
}
