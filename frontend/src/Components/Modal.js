const backgroundSound = new Audio("loadingSound.mp3");
export function showModal(id) {
  return function (maybeTimeout) {
    return function () {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      backgroundSound.play();
      // Set timeout. If after 10 sec nothing happened, something is wrong or the user saw it already.
      if (maybeTimeout.tag === "Just") {
        setTimeout(() => {
          console.log(`Hiding the modal ${id}`);
          backgroundSound.pause();
          backgroundSound.currentTime = 0;
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
    backgroundSound.pause();
    backgroundSound.currentTime = 0;
    modal.hide();
  };
}
