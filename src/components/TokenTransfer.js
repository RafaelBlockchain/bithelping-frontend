import React, { useState } from "react";

const TokenTransfer = ({ contract, account }) => {
  const [recipient, setRecipient] = useState("");
  const [amount, setAmount] = useState("");

  const handleTransfer = async () => {
    try {
      await contract.methods.transferFrom(account, recipient, amount).send({ from: account });
      alert("Tokens transferidos con éxito.");
    } catch (error) {
      console.error("Error en la transferencia de tokens:", error);
    }
  };

  return (
    <div>
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
      <button onClick={handleTransfer}>Transferir Tokens</button>
    </div>
  );
};

export default TokenTransfer;

