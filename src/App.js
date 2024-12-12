// Frontend robusto para BitHelping
// Framework sugerido: React.js con Web3.js o Ethers.js para la interacción con contratos inteligentes

import React, { useState, useEffect } from "react";
import Web3 from "web3";
import { ethers } from "ethers";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from "recharts";
import BitHelpingABI from "./abis/BitHelping.json";
import BitHelpingLiquidityABI from "./abis/BitHelpingLiquidity.json";
import RealTimeLineChart from "./components/charts/RealTimeLineChart";
import { getContract, getBalance } from "./services/contractInteraction";
import TokenTransfer from "./components/TokenTransfer";

const App = () => {
  const [account, setAccount] = useState("");
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [liquidityContract, setLiquidityContract] = useState(null);
  const [balance, setBalance] = useState("0");
  const [amount, setAmount] = useState("");
  const [recipient, setRecipient] = useState("");
  const [transactions, setTransactions] = useState([]); // Historial de transacciones

  const CONTRACT_ADDRESS = "0xYourBitHelpingAddress"; // Reemplaza con la dirección real del contrato
  const LIQUIDITY_CONTRACT_ADDRESS = "0xYourLiquidityContractAddress"; // Reemplaza con la dirección real
  
  // Conectar a MetaMask
  const connectWallet = async () => {
    if (window.ethereum) {
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
    } else {
      alert("MetaMask no está instalada. Por favor, instala MetaMask y recarga la página.");
    }
  };

  // Obtener el balance del usuario
  const getBalance = async () => {
    if (contract && account) {
      const balance = await contract.methods.balanceOf(account).call();
      setBalance(balance);
    }
  };
  
  //Graficos
  return (
  <div className="App">
    <h1>BitHelping Dashboard</h1>
    {!account ? (
      <button onClick={connectWallet}>Conectar Wallet</button>
    ) : (
      <div>
        <p>Cuenta conectada: {account}</p>
        <p>Balance: {balance} BITH</p>

        {/* Sección de Gráficos */}
        <h2>Gráficos en Tiempo Real</h2>
        <RealTimeLineChart data={realTimeData} />
        
        {/* Otras secciones */}
        <h2>Transferencia de Tokens</h2>
        <input
          type="text"
          placeholder="Dirección del destinatario"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
        />
        <input
          type="number"
          placeholder="Cantidad"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
        />
        <button onClick={() => transferTokens(recipient, amount)}>Transferir Tokens</button>
      </div>
    )}
  </div>
);


  // Transferir tokens
  const transferTokens = async (recipient, transferAmount) => {
    if (contract) {
      try {
        await contract.methods.transferFrom(account, recipient, transferAmount).send({ from: account });
        alert("Tokens transferidos con éxito.");

        // Actualizar el historial de transacciones
        setTransactions((prev) => [
          ...prev,
          { date: new Date().toISOString(), amount: transferAmount },
        ]);
      } catch (error) {
        console.error("Error en la transferencia de tokens:", error);
      }
    }
  };

  // Añadir liquidez
  const addLiquidity = async (amountToken, amountETH) => {
    if (liquidityContract) {
      try {
        await liquidityContract.methods
          .addLiquidity(amountToken, 0, 0, Math.floor(Date.now() / 1000) + 60 * 20)
          .send({ from: account, value: ethers.utils.parseEther(amountETH) });
        alert("Liquidez añadida con éxito.");
      } catch (error) {
        console.error("Error al añadir liquidez:", error);
      }
    }
  };

  // Retirar liquidez
  const removeLiquidity = async (liquidity, amountTokenMin, amountETHMin) => {
    if (liquidityContract) {
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

  // Migrar tokens
  const migrateTokens = async (recipient, migrateAmount) => {
    if (contract) {
      try {
        await contract.methods.migrateTokens(recipient, migrateAmount).send({ from: account });
        alert("Tokens migrados con éxito.");
      } catch (error) {
        console.error("Error al migrar tokens:", error);
      }
    }
  };

  // Función para pausar el contrato
  const pauseContract = async () => {
    if (contract) {
      try {
        await contract.methods.pause().send({ from: account });
        alert("Contrato pausado con éxito.");
      } catch (error) {
        console.error("Error al pausar el contrato:", error);
      }
    }
  };

  // Función para reanudar el contrato
  const unpauseContract = async () => {
    if (contract) {
      try {
        await contract.methods.unpause().send({ from: account });
        alert("Contrato reanudado con éxito.");
      } catch (error) {
        console.error("Error al reanudar el contrato:", error);
      }
    }
  };

  useEffect(() => {
    if (contract) {
      getBalance();
    }
  }, [contract]);

  return (
    <div className="App">
      <h1>BitHelping Dashboard</h1>
      {!account ? (
        <button onClick={connectWallet}>Conectar Wallet</button>
      ) : (
        <div>
          <p>Cuenta conectada: {account}</p>
          <p>Balance: {balance} BITH</p>

          <h2>Transferencia de Tokens</h2>
          <input
            type="text"
            placeholder="Dirección del destinatario"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
          />
          <input
            type="number"
            placeholder="Cantidad"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
          <button onClick={() => transferTokens(recipient, amount)}>Transferir Tokens</button>

          <h2>Historial de Transacciones</h2>
          <LineChart width={600} height={300} data={transactions}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="amount" stroke="#82ca9d" />
          </LineChart>

          <h2>Liquidez</h2>
          <button onClick={() => addLiquidity("1000", "0.1")}>Añadir Liquidez</button>
          <button onClick={() => removeLiquidity("100", "10", "0.1")}>Retirar Liquidez</button>

          <h2>Migración de Tokens</h2>
          <input
            type="text"
            placeholder="Dirección del destinatario"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
          />
          <input
            type="number"
            placeholder="Cantidad"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
          <button onClick={() => migrateTokens(recipient, amount)}>Migrar Tokens</button>

          <h2>Gestión del Contrato</h2>
          <button onClick={pauseContract}>Pausar Contrato</button>
          <button onClick={unpauseContract}>Reanudar Contrato</button>
        </div>
      )}
    </div>
  );
};

export default App;

