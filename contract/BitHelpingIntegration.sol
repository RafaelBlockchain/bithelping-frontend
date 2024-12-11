// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBITH.sol";

contract BitHelpingIntegration {
    address public owner;
    IBITH public bithToken;

    // Estructura para almacenar las direcciones de contratos integrados
    mapping(string => address) private integratedContracts;

    // Eventos
    event ContractUpdated(string indexed contractType, address indexed newAddress);
    event TokensStaked(address indexed staker, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMigrated(address indexed user, uint256 amount);
    event FeeCollected(address indexed payer, uint256 amount);
    event ContractPaused(address indexed admin);
    event ContractUnpaused(address indexed admin);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid BITH token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Actualizar la dirección de un contrato integrado
    function updateIntegratedContract(string calldata contractType, address newAddress) external onlyOwner {
        require(bytes(contractType).length > 0, "Contract type is required");
        require(newAddress != address(0), "Invalid address");
        integratedContracts[contractType] = newAddress;
        emit ContractUpdated(contractType, newAddress);
    }

    // Obtener la dirección de un contrato integrado
    function getIntegratedContract(string calldata contractType) external view returns (address) {
        return integratedContracts[contractType];
    }

    // Funciones para interactuar con contratos específicos

    // Función para bloquear tokens en staking
    function stakeTokens(uint256 amount) external {
        address stakingContract = integratedContracts["BitHelpingStaking"];
        require(stakingContract != address(0), "Staking contract not set");
        require(bithToken.transferFrom(msg.sender, stakingContract, amount), "Token transfer failed");
        emit TokensStaked(msg.sender, amount);
    }

    // Función para quemar tokens
    function burnTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        bool success = bithToken.burnTokens(amount); // Asegurarse de que burnTokens retorne un bool
        require(success, "Burn failed");
        emit TokensBurned(msg.sender, amount);
    }

    // Función para migrar tokens
    function migrateTokens(address recipient, uint256 amount) external {
        address migrationContract = integratedContracts["TokenMigration"];
        require(migrationContract != address(0), "Migration contract not set");
        bool success = bithToken.migrateTokens(recipient, amount); // Llamada a migrateTokens
        require(success, "Migration failed");
        emit TokensMigrated(recipient, amount);
    }

    // Función para cobrar tarifas de transacción
    function collectTransactionFee(address payer, uint256 amount) external {
        address tariffContract = integratedContracts["tariffManagement"];
        require(tariffContract != address(0), "Tariff contract not set");
        require(bithToken.transferFrom(payer, tariffContract, amount), "Fee transfer failed");
        emit FeeCollected(payer, amount);
    }

    // Pausar todas las operaciones
    function pauseAll() external onlyOwner {
        require(!bithToken.isPaused(), "Contract already paused");
        bithToken.pause();
        emit ContractPaused(msg.sender);
    }

    // Reanudar todas las operaciones
    function unpauseAll() external onlyOwner {
        require(bithToken.isPaused(), "Contract is not paused");
        bithToken.unpause();
        emit ContractUnpaused(msg.sender);
    }
}
