import { ethers } from "ethers";
import BITH_ABI from './BITH_ABI.json'; // ABI del contrato BitHelping

const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const bithContract = new ethers.Contract(
  "0xCONTRACT_ADDRESS", // Dirección del contrato BITH
  BITH_ABI,
  signer
);

export async function getBalance(address) {
  const balance = await bithContract.balanceOf(address);
  return ethers.utils.formatUnits(balance, 18); // Convertir a formato legible
}

