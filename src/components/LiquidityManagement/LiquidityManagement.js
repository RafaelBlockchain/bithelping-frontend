// src/components/LiquidityManagement/LiquidityManagement.js
import React, { useState } from 'react';
import { BlockchainService } from '../../services/BlockchainService';

const LiquidityManagement = ({ liquidityContract, account }) => {
  const [amountToken, setAmountToken] = useState("");
  const [amountETH, setAmountETH] = useState("");

  const handleAddLiquidity = async () => {
    await BlockchainService.addLiquidity(liquidityContract, account, amountToken, amountETH);
  };

  return (
    <div className="liquidity-management">
      <h2>Gestión de Liquidez</h2>
      <div>
        <input
          type="number"
          placeholder="Cantidad de Token"
          value={amountToken}
          onChange={(e) => setAmountToken(e.target.value)}
        />
        <input
          type="number"
          placeholder="Cantidad de ETH"
          value={amountETH}
          onChange={(e) => setAmountETH(e.target.value)}
        />
        <button onClick={handleAddLiquidity}>Añadir Liquidez</button>
      </div>
    </div>
  );
};

export default LiquidityManagement;

