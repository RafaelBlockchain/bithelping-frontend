import React, { useState, useEffect } from "react";

const TransactionHistory = ({ contract }) => {
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    const fetchTransactions = async () => {
      const txList = await contract.getPastEvents("Transfer", {
        fromBlock: 0,
        toBlock: "latest",
      });
      setTransactions(txList);
    };
    fetchTransactions();
  }, [contract]);

  return (
    <div>
      <h2>Historial de Transacciones</h2>
      <ul>
        {transactions.map((tx, index) => (
          <li key={index}>
            {tx.returnValues.from} transfirió {tx.returnValues.value} a {tx.returnValues.to}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default TransactionHistory;

