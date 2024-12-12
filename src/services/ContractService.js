// src/services/ContractService.js
import Web3 from "web3";
import BitHelpingABI from "../abis/BitHelping.json";

class ContractService {
  constructor(web3Instance, contractAddress) {
    this.web3 = web3Instance;
    this.contract = new web3Instance.eth.Contract(BitHelpingABI, contractAddress);
  }

  // Obtener balance del usuario
  async getBalance(address) {
    try {
      const balance = await this.contract.methods.balanceOf(address).call();
      return balance;
    } catch (error) {
      console.error("Error al obtener el balance:", error);
      throw error;
    }
  }

  // Pausar contrato
  async pauseContract() {
    try {
      await this.contract.methods.pause().send();
    } catch (error) {
      console.error("Error al pausar el contrato:", error);
      throw error;
    }
  }

  // Reanudar contrato
  async unpauseContract() {
    try {
      await this.contract.methods.unpause().send();
    } catch (error) {
      console.error("Error al reanudar el contrato:", error);
      throw error;
    }
  }
}

export default ContractService;
