// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TariffManagement {

    address public owner;
    uint256 public transactionFee; // Tarifa de transacción (0.8%)
    uint256 public stakingFee;     // Tarifa de staking
    uint256 public withdrawalFee; // Tarifa de retiro

    event TransactionFeeUpdated(uint256 oldFee, uint256 newFee);
    event StakingFeeUpdated(uint256 oldFee, uint256 newFee);
    event WithdrawalFeeUpdated(uint256 oldFee, uint256 newFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor inicializando tarifas
    constructor(uint256 _transactionFee, uint256 _stakingFee, uint256 _withdrawalFee) {
        owner = msg.sender;
        transactionFee = _transactionFee; // 0.8% por ejemplo = 80/10000
        stakingFee = _stakingFee;
        withdrawalFee = _withdrawalFee;
    }

    // Función para actualizar la tarifa de transacción
    function updateTransactionFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = transactionFee;
        transactionFee = newFee;
        emit TransactionFeeUpdated(oldFee, newFee);
    }

    // Función para actualizar la tarifa de staking
    function updateStakingFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = stakingFee;
        stakingFee = newFee;
        emit StakingFeeUpdated(oldFee, newFee);
    }

    // Función para actualizar la tarifa de retiro
    function updateWithdrawalFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = withdrawalFee;
        withdrawalFee = newFee;
        emit WithdrawalFeeUpdated(oldFee, newFee);
    }

    // Función para calcular la tarifa de una transacción
    function calculateTransactionFee(uint256 amount) public view returns (uint256) {
        return (amount * transactionFee) / 10000; // Tarifa de 0.8% = 80 / 10000
    }

    // Función para cobrar la tarifa de transacción y realizar la transacción
    function chargeTransactionFee(address sender, uint256 amount) external onlyOwner returns (uint256) {
        uint256 feeAmount = calculateTransactionFee(amount);
        uint256 amountAfterFee = amount - feeAmount;

        // Aquí el contrato puede enviar la tarifa al propietario o a la dirección configurada
        payable(owner).transfer(feeAmount);

        // Devolver el monto restante después de deducir la tarifa
        return amountAfterFee;
    }

    // Función para obtener las tarifas actuales
    function getFees() external view returns (uint256, uint256, uint256) {
        return (transactionFee, stakingFee, withdrawalFee);
    }

    // Función para cobrar la tarifa de staking
    function chargeStakingFee(uint256 amount) external view returns (uint256) {
        uint256 stakingAmountAfterFee = amount - (amount * stakingFee) / 10000;
        return stakingAmountAfterFee;
    }

    // Función para cobrar la tarifa de retiro
    function chargeWithdrawalFee(uint256 amount) external view returns (uint256) {
        uint256 withdrawalAmountAfterFee = amount - (amount * withdrawalFee) / 10000;
        return withdrawalAmountAfterFee;
    }
}

