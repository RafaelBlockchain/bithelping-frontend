import { useState, useEffect } from "react";
import Web3 from "web3";
import BitHelpingABI from "../abis/BitHelping.json";

const useWeb3 = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [error, setError] = useState(null);

  const CONTRACT_ADDRESS = "0xYourBitHelpingAddress"; // Reemplaza con la dirección real del contrato

  useEffect(() => {
    const initializeWeb3 = async () => {
      if (window.ethereum) {
        try {
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);

          const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
          setAccount(accounts[0]);

          const contractInstance = new web3Instance.eth.Contract(BitHelpingABI, CONTRACT_ADDRESS);
          setContract(contractInstance);
        } catch (err) {
          console.error("Error al inicializar Web3:", err);
          setError("No se pudo conectar a MetaMask.");
        }
      } else {
        setError("MetaMask no está instalado. Por favor, instálalo para continuar.");
      }
    };

    initializeWeb3();
  }, []);

  const switchNetwork = async (chainId) => {
    try {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: Web3.utils.toHex(chainId) }],
      });
    } catch (switchError) {
      console.error("Error al cambiar de red:", switchError);
      if (switchError.code === 4902) {
        setError("La red solicitada no está configurada en MetaMask.");
      }
    }
  };

  return { web3, account, contract, error, switchNetwork };
};

export default useWeb3;


