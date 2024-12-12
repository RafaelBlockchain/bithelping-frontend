// src/services/NotificationService.js
export const showSuccessNotification = (message) => {
  // Aquí podrías integrar una librería como Toastr o Snackbar
  alert(`Success: ${message}`);
};

export const showErrorNotification = (message) => {
  // Aquí podrías integrar una librería como Toastr o Snackbar
  alert(`Error: ${message}`);
};

