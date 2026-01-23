export function showLoadingModal(id) {
  return function() {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
  };
}

export function hideLoadingModal(id) {
  return function() {
      const el = document.getElementById(id);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.hide();
  };
}
