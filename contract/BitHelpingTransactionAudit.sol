// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitHelpingTransactionAudit {
    // Structure to store the details of a transaction
    struct Transaction {
        address sender;
        address recipient;
        uint256 amount;
        uint256 timestamp;
    }

    // Mapping to store transactions by ID
    mapping(uint256 => Transaction) public transactions;

    // Counter for the number of registered transactions
    uint256 public transactionCount;

    // Event to notify when a new transaction is recorded
    event TransactionRecorded(
        uint256 transactionId,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );

    // Function to record a transaction
    function recordTransaction(
        address recipient,
        uint256 amount
    ) external returns (uint256) {
        // Ensure the amount is greater than zero
        require(amount > 0, "Amount must be greater than zero");

        // Create a new transaction
        transactionCount++;
        transactions[transactionCount] = Transaction({
            sender: msg.sender,
            recipient: recipient,
            amount: amount,
            timestamp: block.timestamp
        });

        // Emit the event
        emit TransactionRecorded(
            transactionCount,
            msg.sender,
            recipient,
            amount,
            block.timestamp
        );

        return transactionCount; // Return the transaction ID
    }

    // Function to get the details of a transaction by ID
    function getTransaction(uint256 transactionId)
        external
        view
        returns (
            address sender,
            address recipient,
            uint256 amount,
            uint256 timestamp
        )
    {
        Transaction memory txn = transactions[transactionId];
        return (txn.sender, txn.recipient, txn.amount, txn.timestamp);
    }

    // Function to get the total number of registered transactions
    function getTransactionCount() external view returns (uint256) {
        return transactionCount;
    }
}

