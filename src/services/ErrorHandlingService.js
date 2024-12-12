// src/services/ErrorHandlingService.js
class ErrorHandlingService {
  static handleBlockchainError(error) {
    // Lógica para manejar errores relacionados con la blockchain
    console.error("Error de blockchain:", error);
  }

  static handleNetworkError(error) {
    // Lógica para manejar errores de red
    console.error("Error de red:", error);
  }
}

export default ErrorHandlingService;
