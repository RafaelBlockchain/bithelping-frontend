// src/context/NFTContext.js
import React, { createContext, useState, useContext } from 'react';

// Crear el contexto
const NFTContext = createContext();

// Crear el proveedor del contexto
export const NFTProvider = ({ children }) => {
  // Estado global para los NFTs
  const [nfts, setNfts] = useState([]);

  // Función para agregar un nuevo NFT
  const addNFT = (nft) => setNfts([...nfts, nft]);

  return (
    <NFTContext.Provider value={{ nfts, addNFT }}>
      {children}
    </NFTContext.Provider>
  );
};

// Custom hook para usar el contexto
export const useNFTs = () => useContext(NFTContext);

