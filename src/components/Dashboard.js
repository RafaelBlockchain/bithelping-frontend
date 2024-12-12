import React, { useState, useEffect } from "react";
import web3 from "../utils/web3";
import { contractAddress, contractABI } from "../utils/contractABI";
import RealTimeLineChart from "./charts/RealTimeLineChart";

const Dashboard = () => {
  const [balance, setBalance] = useState(0);
  const [account, setAccount] = useState("");
  const [contract, setContract] = useState(null);
  const [realTimeData, setRealTimeData] = useState("");
  
  useEffect(() => {
    const loadBlockchainData = async () => {
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      const realTimeData = await web3.eth.getRealTimeData();
      setRealTimeData(realTimeData[0]);

      const contractInstance = new web3.eth.Contract(contractABI, contractAddress);
      setContract(contractInstance);

      const balance = await contractInstance.methods.balanceOf(accounts[0]).call();
      setBalance(web3.utils.fromWei(balance, "ether"));
    };

    loadBlockchainData();
  }, []);

  return (
    <div>
      <h2>Bienvenido al Dashboard</h2>
      <p>Saldo de BITH: {balance} BITH</p>
      <p>Cuenta conectada: {account}</p>
      <p>Balance: {balance} BITH</p>

       {/* Sección de gráficos */}
      <h2>Gráficos en Tiempo Real</h2>
      <RealTimeLineChart data={realTimeData} />
    </div>
  );
};

export default Dashboard;

