import { ethers } from "ethers";
import { BITH_CONTRACT } from "./contracts";

const getContract = () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  return new ethers.Contract(BITH_CONTRACT.address, BITH_CONTRACT.abi, signer);
};

export const getBalance = async (address) => {
  const contract = getContract();
  return await contract.balanceOf(address);
};

export const stakeTokens = async (amount) => {
  const contract = getContract();
  return await contract.stakeTokens(ethers.utils.parseEther(amount));
};

