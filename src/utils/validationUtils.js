// src/utils/validationUtils.js
export const isValidAddress = (address) => {
  return Web3.utils.isAddress(address);
};

