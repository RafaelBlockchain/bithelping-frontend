import React, { useState } from "react";

const StakingRewards = ({ contract }) => {
  const [amount, setAmount] = useState("");

  const stakeTokens = async () => {
    await contract.methods.stake(amount).send({ from: account });
  };

  const claimRewards = async () => {
    await contract.methods.claimRewards().send({ from: account });
  };

  return (
    <div>
      <h2>Staking de Recompensas</h2>
      <input
        type="number"
        placeholder="Cantidad"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button onClick={stakeTokens}>Hacer Stake</button>
      <button onClick={claimRewards}>Reclamar Recompensas</button>
    </div>
  );
};

export default StakingRewards;

