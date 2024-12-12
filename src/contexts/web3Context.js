import React, { createContext, useState } from "react";
import Web3 from "web3";

export const Web3Context = createContext();

export const Web3Provider = ({ children }) => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState("");
  const [connector, setConnector] = useState(null);

  const connectWalletConnect = async (walletConnect) => {
    try {
      await walletConnect.activate();
      const provider = await walletConnect.getProvider();
      const web3Instance = new Web3(provider);
      setWeb3(web3Instance);

      const accounts = await web3Instance.eth.getAccounts();
      setAccount(accounts[0]);
      setConnector(walletConnect);

      walletConnect.on("disconnect", () => {
        setWeb3(null);
        setAccount("");
        setConnector(null);
      });
    } catch (error) {
      console.error("Error al conectar WalletConnect:", error);
    }
  };

  return (
    <Web3Context.Provider
      value={{
        web3,
        account,
        connectWalletConnect,
      }}
    >
      {children}
    </Web3Context.Provider>
  );
};

