// src/context/ContractContext.js
import React, { createContext, useState, useContext } from 'react';

const ContractContext = createContext();

export const ContractProvider = ({ children }) => {
  const [contract, setContract] = useState(null);

  const setNewContract = (newContract) => {
    setContract(newContract);
  };

  return (
    <ContractContext.Provider value={{ contract, setNewContract }}>
      {children}
    </ContractContext.Provider>
  );
};

export const useContract = () => useContext(ContractContext);

