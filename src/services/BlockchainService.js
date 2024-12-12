// src/services/BlockchainService.js
import Web3 from "web3";
import BitHelpingABI from "../abis/BitHelping.json";
import BitHelpingLiquidityABI from "../abis/BitHelpingLiquidity.json";
const CONTRACT_ADDRESS = "0xYourBitHelpingAddress";
const LIQUIDITY_CONTRACT_ADDRESS = "0xYourLiquidityContractAddress";

export const connectWallet = async () => {
  if (window.ethereum) {
    const web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: "eth_requestAccounts" });
    const account = (await web3.eth.getAccounts())[0];
    const contract = new web3.eth.Contract(BitHelpingABI, CONTRACT_ADDRESS);
    const liquidityContract = new web3.eth.Contract(BitHelpingLiquidityABI, LIQUIDITY_CONTRACT_ADDRESS);
    return { web3, account, contract, liquidityContract };
  }
  return null;
};

export const fetchBalance = async (web3, contract, account) => {
  const balance = await contract.methods.balanceOf(account).call();
  return balance;
};

export const transferTokens = async (web3, contract, account, recipient, amount) => {
  await contract.methods.transferFrom(account, recipient, amount).send({ from: account });
};

export const addLiquidity = async (web3, liquidityContract, account, amountToken, amountETH) => {
  await liquidityContract.methods
    .addLiquidity(amountToken, 0, 0, Math.floor(Date.now() / 1000) + 60 * 20)
    .send({ from: account, value: Web3.utils.toWei(amountETH, 'ether') });
};

