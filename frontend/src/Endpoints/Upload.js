"use strict";

// PureScript calls this as fileToFormData(file)(filename), so we must be curried:
// file -> filename -> (() -> FormData). The innermost 0-arg function is the Effect thunk.
export const fileToFormData = function (file) {
  return function (filename) {
    return function () {
      var fd = new FormData();
      fd.append("file", file, filename);
      return fd;
    };
  };
};

export const formDataToRequestBody = function (fd) {
  return fd;
};
