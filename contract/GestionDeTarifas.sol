// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TariffManagement {

    address public owner;
    uint256 public transactionFee; // Tarifa por cada transacción
    uint256 public stakingFee; // Tarifa por staking
    uint256 public withdrawalFee; // Tarifa por retiro

    event TransactionFeeUpdated(uint256 newFee);
    event StakingFeeUpdated(uint256 newFee);
    event WithdrawalFeeUpdated(uint256 newFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(uint256 _transactionFee, uint256 _stakingFee, uint256 _withdrawalFee) {
        owner = msg.sender;
        transactionFee = _transactionFee;
        stakingFee = _stakingFee;
        withdrawalFee = _withdrawalFee;
    }

    // Función para actualizar la tarifa de transacción
    function updateTransactionFee(uint256 _newFee) external onlyOwner {
        transactionFee = _newFee;
        emit TransactionFeeUpdated(_newFee);
    }

    // Función para actualizar la tarifa de staking
    function updateStakingFee(uint256 _newFee) external onlyOwner {
        stakingFee = _newFee;
        emit StakingFeeUpdated(_newFee);
    }

    // Función para actualizar la tarifa de retiro
    function updateWithdrawalFee(uint256 _newFee) external onlyOwner {
        withdrawalFee = _newFee;
        emit WithdrawalFeeUpdated(_newFee);
    }

    // Función para obtener las tarifas actuales
    function getFees() external view returns (uint256, uint256, uint256) {
        return (transactionFee, stakingFee, withdrawalFee);
    }
}

