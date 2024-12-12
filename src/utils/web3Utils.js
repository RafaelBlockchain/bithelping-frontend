// src/utils/web3Utils.js

import Web3 from "web3";

// Convertir entre unidades de Ethereum
export const toWei = (value) => Web3.utils.toWei(value.toString(), "ether");
export const fromWei = (value) => Web3.utils.fromWei(value.toString(), "ether");

// Verificar si una dirección es válida
export const isValidAddress = (address) => Web3.utils.isAddress(address);

// Crear instancia de un contrato
export const getContractInstance = (abi, address, web3Instance) => {
  return new web3Instance.eth.Contract(abi, address);
};

// Manejo de errores comunes
export const handleWeb3Error = (error) => {
  if (error.message.includes("User denied transaction signature")) {
    return "El usuario rechazó la transacción.";
  }
  return "Ocurrió un error en la interacción con la blockchain.";
};
