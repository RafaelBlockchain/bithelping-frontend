import Web3 from "web3";
import BitHelpingABI from "../abis/BitHelping.json";

const CONTRACT_ADDRESS = "0xYourBitHelpingAddress";

// Configura web3 y el contrato
export const getContract = async () => {
  if (window.ethereum) {
    const web3Instance = new Web3(window.ethereum);
    const contract = new web3Instance.eth.Contract(BitHelpingABI, CONTRACT_ADDRESS);
    return { web3Instance, contract };
  } else {
    throw new Error("MetaMask no está instalado");
  }
};

// Obtener balance
export const getBalance = async (contract, account) => {
  const balance = await contract.methods.balanceOf(account).call();
  return balance;
};

// Transferir tokens
export const transferTokens = async (contract, account, recipient, amount) => {
  await contract.methods.transferFrom(account, recipient, amount).send({ from: account });
};

