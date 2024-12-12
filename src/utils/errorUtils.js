// src/utils/errorUtils.js

export const formatErrorMessage = (error) => {
  if (error.response && error.response.data) {
    return error.response.data.message || "Error desconocido.";
  }
  return error.message || "Error desconocido.";
};
