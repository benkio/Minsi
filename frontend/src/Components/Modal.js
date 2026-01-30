export function showModal(id) {
  return function() {
    const el = document.getElementById(id);
    if (el) {
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
    }
  };
}

export function hideModal(id) {
  return function() {
    const el = document.getElementById(id);
    if (el) {
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.hide();
    }
  };
}
