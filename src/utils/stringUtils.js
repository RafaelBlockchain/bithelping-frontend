// src/utils/stringUtils.js

export const truncateString = (str, length) => {
  return str.length > length ? `${str.substring(0, length)}...` : str;
};

export const capitalizeFirstLetter = (str) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};
