"use strict";

export const fileToFormData = function (file, filename) {
  return function () {
    var fd = new FormData();
    fd.append("file", file, filename);
    return fd;
  };
};

export const formDataToRequestBody = function (fd) {
  return fd;
};
