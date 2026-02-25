"use strict";

export const fileToFormData = function (file, filename) {
  return function () {
    console.log(`[fileToformdata] create FormData`);
    var fd = new FormData();
    console.log(`[fileToformdata] append file`);
    fd.append("file", file, filename);
    console.log(`[fileToformdata] return`);
    return fd;
  };
};

export const formDataToRequestBody = function (fd) {
  console.log(`[formDataToRequestBody] return`);
  return fd;
};
