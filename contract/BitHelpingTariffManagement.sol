// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitHelpingTariffManagement {

    address public owner;
    uint256 public transactionFee; // Transaction fee (1.8%)
    uint256 public stakingFee;     // Staking fee
    uint256 public withdrawalFee;  // Withdrawal fee

    event TransactionFeeUpdated(uint256 oldFee, uint256 newFee);
    event StakingFeeUpdated(uint256 oldFee, uint256 newFee);
    event WithdrawalFeeUpdated(uint256 oldFee, uint256 newFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor initializing fees
    constructor(uint256 _transactionFee, uint256 _stakingFee, uint256 _withdrawalFee) {
        owner = msg.sender;
        transactionFee = _transactionFee; // For example, 1.8% = 180/10000
        stakingFee = _stakingFee;
        withdrawalFee = _withdrawalFee;
    }

    // Function to update the transaction fee
    function updateTransactionFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = transactionFee;
        transactionFee = newFee;
        emit TransactionFeeUpdated(oldFee, newFee);
    }

    // Function to update the staking fee
    function updateStakingFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = stakingFee;
        stakingFee = newFee;
        emit StakingFeeUpdated(oldFee, newFee);
    }

    // Function to update the withdrawal fee
    function updateWithdrawalFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = withdrawalFee;
        withdrawalFee = newFee;
        emit WithdrawalFeeUpdated(oldFee, newFee);
    }

    // Function to calculate the transaction fee
    function calculateTransactionFee(uint256 amount) public view returns (uint256) {
        return (amount * transactionFee) / 10000; // 1.8% fee = 180 / 10000
    }

    // Function to charge the transaction fee and perform the transaction
    function chargeTransactionFee(uint256 amount) external onlyOwner returns (uint256) {
        uint256 feeAmount = calculateTransactionFee(amount);
        uint256 amountAfterFee = amount - feeAmount;

        // Here the contract can send the fee to the owner or the configured address
        payable(owner).transfer(feeAmount);

        // Return the remaining amount after the fee deduction
        return amountAfterFee;
    }

    // Function to get the current fees
    function getFees() external view returns (uint256, uint256, uint256) {
        return (transactionFee, stakingFee, withdrawalFee);
    }

    // Function to charge the staking fee
    function chargeStakingFee(uint256 amount) external view returns (uint256) {
        uint256 stakingAmountAfterFee = amount - (amount * stakingFee) / 10000;
        return stakingAmountAfterFee;
    }

    // Function to charge the withdrawal fee
    function chargeWithdrawalFee(uint256 amount) external view returns (uint256) {
        uint256 withdrawalAmountAfterFee = amount - (amount * withdrawalFee) / 10000;
        return withdrawalAmountAfterFee;
    }
}

