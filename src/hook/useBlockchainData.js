import { useState, useEffect } from "react";
import Web3 from "web3";
import BitHelpingABI from "../abis/BitHelping.json";
import BitHelpingLiquidityABI from "../abis/BitHelpingLiquidity.json";

const CONTRACT_ADDRESS = "0xYourBitHelpingAddress"; // Reemplaza con la dirección real del contrato
const LIQUIDITY_CONTRACT_ADDRESS = "0xYourLiquidityContractAddress"; // Reemplaza con la dirección real

const useBlockchainData = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [liquidityContract, setLiquidityContract] = useState(null);
  const [balance, setBalance] = useState("0");

  // Inicialización de Web3 y contratos
  useEffect(() => {
    const initBlockchain = async () => {
      if (window.ethereum) {
        try {
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);

          const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
          setAccount(accounts[0]);

          const bitHelpingContract = new web3Instance.eth.Contract(BitHelpingABI, CONTRACT_ADDRESS);
          setContract(bitHelpingContract);

          const bitHelpingLiquidityContract = new web3Instance.eth.Contract(
            BitHelpingLiquidityABI,
            LIQUIDITY_CONTRACT_ADDRESS
          );
          setLiquidityContract(bitHelpingLiquidityContract);
        } catch (error) {
          console.error("Error al inicializar la blockchain:", error);
        }
      } else {
        console.error("MetaMask no está instalada. Por favor, instala MetaMask y recarga la página.");
      }
    };

    initBlockchain();
  }, []);

  // Obtener el balance del usuario
  const fetchBalance = async () => {
    if (contract && account) {
      try {
        const userBalance = await contract.methods.balanceOf(account).call();
        setBalance(userBalance);
      } catch (error) {
        console.error("Error al obtener el balance:", error);
      }
    }
  };

  // Transferencia de tokens
  const transferTokens = async (recipient, amount) => {
    if (contract && account) {
      try {
        await contract.methods.transfer(recipient, amount).send({ from: account });
        alert("Tokens transferidos con éxito.");
        fetchBalance();
      } catch (error) {
        console.error("Error al transferir tokens:", error);
      }
    }
  };

  // Añadir liquidez
  const addLiquidity = async (amountToken, amountETH) => {
    if (liquidityContract && account) {
      try {
        await liquidityContract.methods
          .addLiquidity(amountToken, 0, 0, Math.floor(Date.now() / 1000) + 60 * 20)
          .send({ from: account, value: Web3.utils.toWei(amountETH, "ether") });
        alert("Liquidez añadida con éxito.");
      } catch (error) {
        console.error("Error al añadir liquidez:", error);
      }
    }
  };

  // Retirar liquidez
  const removeLiquidity = async (liquidity, amountTokenMin, amountETHMin) => {
    if (liquidityContract && account) {
      try {
        await liquidityContract.methods
          .removeLiquidity(liquidity, amountTokenMin, amountETHMin, Math.floor(Date.now() / 1000) + 60 * 20)
          .send({ from: account });
        alert("Liquidez retirada con éxito.");
      } catch (error) {
        console.error("Error al retirar liquidez:", error);
      }
    }
  };

  useEffect(() => {
    if (contract && account) {
      fetchBalance();
    }
  }, [contract, account]);

  return {
    web3,
    account,
    balance,
    fetchBalance,
    transferTokens,
    addLiquidity,
    removeLiquidity,
  };
};

export default useBlockchainData;
