const backgroundSound = new Audio('loadingSound.mp3')
export function showModal(id) {
  return function (enableTimeout) {
    return function () {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      backgroundSound.play();
      // Set timeout. If after 10 sec nothing happened, something is wrong or the user saw it already.
      if (enableTimeout) {
        setTimeout(() => {
          backgroundSound.pause();
          backgroundSound.currentTime = 0;
          modal.hide(id);
        }, 10000);
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
