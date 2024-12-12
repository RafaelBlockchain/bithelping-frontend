// src/utils/web3Utils.js
export const toWei = (amount) => {
  return Web3.utils.toWei(amount.toString(), "ether");
};

export const fromWei = (amount) => {
  return Web3.utils.fromWei(amount.toString(), "ether");
};

