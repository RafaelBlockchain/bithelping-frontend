// src/services/TransactionService.js
import Web3 from "web3";
import { blockchainErrorHandler } from "../utils/errorHandlers";

class TransactionService {
  constructor(web3Instance, contract) {
    this.web3 = web3Instance;
    this.contract = contract;
  }

  // Realizar transferencia de tokens
  async transferTokens(fromAddress, toAddress, amount) {
    try {
      const result = await this.contract.methods
        .transfer(toAddress, amount)
        .send({ from: fromAddress });
      return result;
    } catch (error) {
      blockchainErrorHandler(error);
      throw new Error("Error en la transferencia de tokens.");
    }
  }

  // Agregar liquidez
  async addLiquidity(fromAddress, tokenAmount, ethAmount) {
    try {
      const result = await this.contract.methods
        .addLiquidity(tokenAmount, 0, 0, Math.floor(Date.now() / 1000) + 60 * 20)
        .send({ from: fromAddress, value: Web3.utils.toWei(ethAmount, 'ether') });
      return result;
    } catch (error) {
      blockchainErrorHandler(error);
      throw new Error("Error al agregar liquidez.");
    }
  }
}

export default TransactionService;
