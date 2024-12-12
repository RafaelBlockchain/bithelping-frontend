// src/services/LiquidityService.js
import Web3 from "web3";
import { LiquidityABI } from "../abis/LiquidityABI";

class LiquidityService {
  constructor(web3Instance, liquidityContractAddress) {
    this.web3 = web3Instance;
    this.liquidityContract = new web3Instance.eth.Contract(LiquidityABI, liquidityContractAddress);
  }

  async addLiquidity(address, amountToken, amountETH) {
    try {
      const result = await this.liquidityContract.methods
        .addLiquidity(amountToken, amountETH)
        .send({ from: address, value: Web3.utils.toWei(amountETH, 'ether') });
      return result;
    } catch (error) {
      console.error("Error al añadir liquidez:", error);
      throw error;
    }
  }

  async removeLiquidity(address, liquidityAmount) {
    try {
      const result = await this.liquidityContract.methods
        .removeLiquidity(liquidityAmount)
        .send({ from: address });
      return result;
    } catch (error) {
      console.error("Error al retirar liquidez:", error);
      throw error;
    }
  }
}

export default LiquidityService;
