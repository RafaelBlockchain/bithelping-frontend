// src/utils/validationUtils.js

// Validar que un valor es un número positivo
export const isPositiveNumber = (value) => {
  return !isNaN(value) && Number(value) > 0;
};

// Validar que un string tiene formato de dirección Ethereum
export const isEthereumAddress = (address) => {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
};

// Validar que un hash es válido
export const isValidHash = (hash) => {
  return /^0x[a-fA-F0-9]{64}$/.test(hash);
};

// Validar que un campo no esté vacío
export const isNotEmpty = (value) => {
  return value.trim().length > 0;
};
