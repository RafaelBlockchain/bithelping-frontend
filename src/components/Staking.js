import React, { useState } from "react";

const Staking = ({ contract }) => {
  const [amount, setAmount] = useState("");

  const stakeTokens = async () => {
    await contract.methods.stakeTokens(web3.utils.toWei(amount, "ether")).send({ from: window.ethereum.selectedAddress });
    alert("Tokens apostados exitosamente.");
  };

  return (
    <div>
      <h3>Staking de Tokens</h3>
      <input
        type="text"
        placeholder="Cantidad a apostar"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button onClick={stakeTokens}>Apostar Tokens</button>
    </div>
  );
};

export default Staking;

