// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBITH.sol";

contract BitHelpingIntegration {
    address public owner;
    IBITH public bithToken;

    // Direcciones de contratos integrados
    address public stakingContract;
    address public marketplaceContract;
    address public distributionContract;
    address public governanceContract;
    address public liquidityContract;
    address public auditContract;
    address public tariffManagementContract;
    address public migrationContract;
    address public charityContract;
    address public oracleIntegrationContract;
    address public paypalIntegrationContract;

    // Eventos
    event ContractUpdated(string indexed contractType, address indexed newAddress);
    event TokensStaked(address indexed staker, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMigrated(address indexed user, uint256 amount);
    event FeeCollected(address indexed payer, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid BITH token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Actualizar direcciones de contratos integrados
    function updateStakingContract(address _stakingContract) external onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        stakingContract = _stakingContract;
        emit ContractUpdated("Staking", _stakingContract);
    }

    function updateMarketplaceContract(address _marketplaceContract) external onlyOwner {
        require(_marketplaceContract != address(0), "Invalid address");
        marketplaceContract = _marketplaceContract;
        emit ContractUpdated("Marketplace", _marketplaceContract);
    }

    function updateDistributionContract(address _distributionContract) external onlyOwner {
        require(_distributionContract != address(0), "Invalid address");
        distributionContract = _distributionContract;
        emit ContractUpdated("Distribution", _distributionContract);
    }

    function updateGovernanceContract(address _governanceContract) external onlyOwner {
        require(_governanceContract != address(0), "Invalid address");
        governanceContract = _governanceContract;
        emit ContractUpdated("Governance", _governanceContract);
    }

    function updateLiquidityContract(address _liquidityContract) external onlyOwner {
        require(_liquidityContract != address(0), "Invalid address");
        liquidityContract = _liquidityContract;
        emit ContractUpdated("Liquidity", _liquidityContract);
    }

    function updateAuditContract(address _auditContract) external onlyOwner {
        require(_auditContract != address(0), "Invalid address");
        auditContract = _auditContract;
        emit ContractUpdated("Audit", _auditContract);
    }

    function updateTariffManagementContract(address _tariffManagementContract) external onlyOwner {
        require(_tariffManagementContract != address(0), "Invalid address");
        tariffManagementContract = _tariffManagementContract;
        emit ContractUpdated("TariffManagement", _tariffManagementContract);
    }

    function updateMigrationContract(address _migrationContract) external onlyOwner {
        require(_migrationContract != address(0), "Invalid address");
        migrationContract = _migrationContract;
        emit ContractUpdated("Migration", _migrationContract);
    }

    function updateCharityContract(address _charityContract) external onlyOwner {
        require(_charityContract != address(0), "Invalid address");
        charityContract = _charityContract;
        emit ContractUpdated("Charity", _charityContract);
    }

    function updateOracleIntegrationContract(address _oracleIntegrationContract) external onlyOwner {
        require(_oracleIntegrationContract != address(0), "Invalid address");
        oracleIntegrationContract = _oracleIntegrationContract;
        emit ContractUpdated("OracleIntegration", _oracleIntegrationContract);
    }

    function updatePaypalIntegrationContract(address _paypalIntegrationContract) external onlyOwner {
        require(_paypalIntegrationContract != address(0), "Invalid address");
        paypalIntegrationContract = _paypalIntegrationContract;
        emit ContractUpdated("PaypalIntegration", _paypalIntegrationContract);
    }

    // Funciones para interactuar con contratos específicos
    function stakeTokens(uint256 amount) external {
        require(stakingContract != address(0), "Staking contract not set");
        bithToken.transferFrom(msg.sender, stakingContract, amount);
        emit TokensStaked(msg.sender, amount);
    }

    function burnTokens(uint256 amount) external {
        bithToken.burnTokens(amount);
        emit TokensBurned(msg.sender, amount);
    }

    function migrateTokens(address recipient, uint256 amount) external {
        require(migrationContract != address(0), "Migration contract not set");
        bithToken.migrateTokens(recipient, amount);
        emit TokensMigrated(recipient, amount);
    }

    function collectTransactionFee(address payer, uint256 amount) external {
        require(tariffManagementContract != address(0), "Tariff contract not set");
        bithToken.transferFrom(payer, tariffManagementContract, amount);
        emit FeeCollected(payer, amount);
    }

    // Pausar y reanudar todas las operaciones
    function pauseAll() external onlyOwner {
        bithToken.pause();
    }

    function unpauseAll() external onlyOwner {
        bithToken.unpause();
    }
}
