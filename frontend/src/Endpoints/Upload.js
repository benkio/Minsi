"use strict";

export const fileToFormData = function (file) {
  return function () {
    var fd = new FormData();
    fd.append("file", file);
    return fd;
  };
};

export const formDataToRequestBody = function (fd) {
  return fd;
};
