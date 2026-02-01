export function showModal(id) {
  return function () {
    const el = document.getElementById(id);
    const modal = bootstrap.Modal.getOrCreateInstance(el);
    modal.show();
    // Set timeout. If after 10 sec nothing happened, something is wrong or the user saw it already.
    setTimeout(() => {
      modal.hide(id);
    }, 10000);
  };
}

export function hideModal(id) {
  return function () {
    const el = document.getElementById(id);
    const modal = bootstrap.Modal.getOrCreateInstance(el);
    modal.hide();
  };
}
