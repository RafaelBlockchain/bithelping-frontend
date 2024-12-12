// src/utils/mathUtils.js

export const calculatePercentage = (partialValue, totalValue) => {
  return ((partialValue / totalValue) * 100).toFixed(2);
};

export const roundToDecimals = (num, decimals = 2) => {
  return parseFloat(num.toFixed(decimals));
};
