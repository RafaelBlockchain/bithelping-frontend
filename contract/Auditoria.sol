// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionAudit {
    // Estructura para almacenar los detalles de una transacción
    struct Transaction {
        address sender;
        address recipient;
        uint256 amount;
        uint256 timestamp;
    }

    // Mapeo para almacenar las transacciones por ID
    mapping(uint256 => Transaction) public transactions;

    // Contador para la cantidad de transacciones registradas
    uint256 public transactionCount;

    // Evento para notificar cuando una nueva transacción sea registrada
    event TransactionRecorded(
        uint256 transactionId,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );

    // Función para registrar una transacción
    function recordTransaction(
        address recipient,
        uint256 amount
    ) external returns (uint256) {
        // Asegurarse de que el monto sea mayor que cero
        require(amount > 0, "Amount must be greater than zero");

        // Crear una nueva transacción
        transactionCount++;
        transactions[transactionCount] = Transaction({
            sender: msg.sender,
            recipient: recipient,
            amount: amount,
            timestamp: block.timestamp
        });

        // Emitir el evento
        emit TransactionRecorded(
            transactionCount,
            msg.sender,
            recipient,
            amount,
            block.timestamp
        );

        return transactionCount; // Devuelve el ID de la transacción
    }

    // Función para obtener los detalles de una transacción por ID
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

    // Función para obtener el total de transacciones registradas
    function getTransactionCount() external view returns (uint256) {
        return transactionCount;
    }
}

