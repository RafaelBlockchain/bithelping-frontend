import React, { useState, useEffect } from "react";
import web3 from "../utils/web3";
import { contractAddress, contractABI } from "../utils/contractABI";

const Dashboard = () => {
  const [balance, setBalance] = useState(0);
  const [account, setAccount] = useState("");
  const [contract, setContract] = useState(null);

  useEffect(() => {
    const loadBlockchainData = async () => {
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      const contractInstance = new web3.eth.Contract(contractABI, contractAddress);
      setContract(contractInstance);

      const balance = await contractInstance.methods.balanceOf(accounts[0]).call();
      setBalance(web3.utils.fromWei(balance, "ether"));
    };

    loadBlockchainData();
  }, []);

  return (
    <div>
      <h2>Bienvenido, {account}</h2>
      <p>Saldo de BITH: {balance} BITH</p>
    </div>
  );
};

export default Dashboard;

