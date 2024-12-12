// src/App.js

import React, { useState, useEffect } from "react";
import Web3 from "web3";
import { ethers } from "ethers";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from "recharts";
import BitHelpingABI from "./abis/BitHelping.json";
import BitHelpingLiquidityABI from "./abis/BitHelpingLiquidity.json";
import { Web3Provider } from "./contexts/web3Context";
import { UserProvider, useUser } from "./contexts/UserContext"; // Importar UserContext
import { walletConnect } from "./utils/walletConnect"; // Importar walletConnect
import RealTimeLineChart from "./components/charts/RealTimeLineChart";
import RealTimeNotifications from "./notifications/RealTimeNotifications";
import TokenTransfer from "./components/TokenTransfer";

// Definir las direcciones de los contratos
const CONTRACT_ADDRESS = "0xYourBitHelpingAddress"; // Reemplaza con la dirección real del contrato
const LIQUIDITY_CONTRACT_ADDRESS = "0xYourLiquidityContractAddress"; // Reemplaza con la dirección real

const App = () => {
  const { user, login, logout } = useUser(); // Acceder al contexto de usuario
  const [account, setAccount] = useState("");
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [liquidityContract, setLiquidityContract] = useState(null);
  const [balance, setBalance] = useState("0");
  const [amount, setAmount] = useState("");
  const [recipient, setRecipient] = useState("");
  const [transactions, setTransactions] = useState([]); // Historial de transacciones

  // Conectar a MetaMask utilizando walletConnect
  const connectWallet = async () => {
    walletConnect(setWeb3, setAccount, setContract, setLiquidityContract); // Usar la función walletConnect
    login({ name: "Juan", address: account }); // Simulando un login con datos de MetaMask
  };

  // Obtener el balance del usuario
  const fetchBalance = async () => {
    if (contract && account) {
      try {
        const balance = await contract.methods.balanceOf(account).call();
        setBalance(balance);
      } catch (error) {
        console.error("Error al obtener el balance:", error);
      }
    }
  };

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

  useEffect(() => {
    if (contract) {
      fetchBalance();
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

          {/* Mostrar el nombre del usuario desde el contexto */}
          {user && <p>Bienvenido, {user.name}!</p>}

          {/* Sección de Gráficos */}
          <h2>Gráficos en Tiempo Real</h2>
          <RealTimeLineChart data={transactions} />

          {/* Transferencia de Tokens */}
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

          {/* Historial de Transacciones */}
          <h2>Historial de Transacciones</h2>
          <LineChart width={600} height={300} data={transactions}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="amount" stroke="#82ca9d" />
          </LineChart>

          {/* Notificaciones en Tiempo Real */}
          <RealTimeNotifications contract={contract} account={account} />
        </div>
      )}
    </div>
  );
};

// Envolver la app con Web3Provider y UserProvider
const RootApp = () => (
  <Web3Provider>
    <UserProvider>
      <App />
    </UserProvider>
  </Web3Provider>
);

export default RootApp;

// Componentes auxiliares

// ThemeSwitcher.js
import React from 'react';
import { useTheme } from '../context/ThemeContext';

const ThemeSwitcher = () => {
  const { theme, toggleTheme } = useTheme();
  return (
    <button onClick={toggleTheme}>
      Cambiar a modo {theme === 'light' ? 'oscuro' : 'claro'}
    </button>
  );
};

// NotificationList.js
import React from 'react';
import { useNotifications } from '../context/NotificationsContext';

const NotificationList = () => {
  const { notifications } = useNotifications();

  return (
    <div className="notifications">
      {notifications.map((notification, index) => (
        <div key={index} className="notification">
          {notification}
        </div>
      ))}
    </div>
  );
};

// TransactionHistory.js
import React from 'react';
import { useTransactions } from '../context/TransactionContext';

const TransactionHistory = () => {
  const { transactions } = useTransactions();

  return (
    <div>
      <h3>Historial de Transacciones</h3>
      <ul>
        {transactions.map((transaction, index) => (
          <li key={index}>
            <p>Fecha: {transaction.date}</p>
            <p>Tipo: {transaction.type}</p>
            <p>Monto: {transaction.amount}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

// ContractDetails.js
import React, { useEffect } from 'react';
import { useContract } from '../context/ContractContext';

const ContractDetails = () => {
  const { contract, setNewContract } = useContract();

  useEffect(() => {
    // Código para interactuar con el contrato
  }, [contract]);

  return (
    <div>
      <h2>Detalles del Contrato</h2>
      <p>Dirección del contrato: {contract ? contract.options.address : 'Cargando...'}</p>
    </div>
  );
};






