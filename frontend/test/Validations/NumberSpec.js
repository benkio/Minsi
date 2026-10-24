export const createInputWithValue = (value) => () => {
  const input = globalThis.document.createElement("input");
  input.type = "number";
  input.value = value;
  return input;
};
