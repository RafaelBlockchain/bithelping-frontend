// src/services/WalletService.js
class WalletService {
  static async connectWallet() {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: 'eth_requestAccounts',
        });
        return accounts[0]; // La primera cuenta conectada
      } catch (error) {
        console.error("Error al conectar con MetaMask:", error);
        throw error;
      }
    } else {
      throw new Error("MetaMask no está instalada.");
    }
  }

  static async disconnectWallet() {
    // Lógica para desconectar la wallet (si aplica)
  }
}

export default WalletService;
