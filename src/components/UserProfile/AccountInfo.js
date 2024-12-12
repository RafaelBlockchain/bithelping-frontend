// src/components/UserProfile/AccountInfo.js
import React, { useContext } from 'react';
import { Web3Context } from '../../contexts/web3Context';

const AccountInfo = () => {
  const { account, balance } = useContext(Web3Context);

  return (
    <div className="account-info">
      <h2>Mi Cuenta</h2>
      <p>Dirección de Wallet: {account}</p>
      <p>Balance: {balance} BITH</p>
    </div>
  );
};

export default AccountInfo;

