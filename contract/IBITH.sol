// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    // Funciones estándar de ERC-20
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint256);

    // Funciones específicas de BitHelping
    function burnTokens(uint256 amount) external;
    function stakeTokens(uint256 amount) external;
    function claimStakingRewards() external;
    function migrateTokens(address recipient, uint256 amount) external;

    // Funciones de gestión
    function setTransactionFee(uint256 fee) external;
    function setFeeRecipient(address feeRecipient) external;
    function exemptFromFees(address account, bool exempt) external;

    // Funciones de pausa
    function pause() external;
    function unpause() external;
    function isPaused() external view returns (bool);
}

