// src/components/TransactionHistory/TransactionHistory.js
import React, { useEffect, useState } from 'react';

const TransactionHistory = ({ contract, account }) => {
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    const fetchTransactions = async () => {
      // Lógica para obtener las transacciones desde el contrato o API
      const data = await contract.methods.getTransactions(account).call();
      setTransactions(data);
    };

    if (contract && account) {
      fetchTransactions();
    }
  }, [contract, account]);

  return (
    <div className="transaction-history">
      <h2>Historial de Transacciones</h2>
      <ul>
        {transactions.map((txn, index) => (
          <li key={index}>
            <p>Fecha: {txn.date}</p>
            <p>Tipo: {txn.type}</p>
            <p>Monto: {txn.amount}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default TransactionHistory;

