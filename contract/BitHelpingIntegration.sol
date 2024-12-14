// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface IBHELP {
    // Function to transfer tokens from one contract to another
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Function to allow contracts to mint new tokens
    function mint(address to, uint256 amount) external;

    // Function to burn tokens
    function burnTokens(uint256 amount) external returns (bool);

    // Function to pause contract operations (only owner)
    function pause() external;

    // Function to resume contract operations (only owner)
    function unpause() external;

    // Function to check if the contract is paused
    function isPaused() external view returns (bool);  
    
    // Function to migrate tokens
    function migrateTokens(address recipient, uint256 amount) external returns (bool); 
}

contract BitHelpingIntegration {
    address public owner;
    IBHELP public bithToken;

    // Structure to store integrated contract addresses
    mapping(string => address) private integratedContracts;

    // Events
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
        require(_bithToken != address(0), "Invalid BHELP token address");
        owner = msg.sender;
        bithToken = IBHELP(_bithToken);
    }

    // Update the address of an integrated contract
    function updateIntegratedContract(string calldata contractType, address newAddress) external onlyOwner {
        require(bytes(contractType).length > 0, "Contract type is required");
        require(newAddress != address(0), "Invalid address");
        integratedContracts[contractType] = newAddress;
        emit ContractUpdated(contractType, newAddress);
    }

    // Get the address of an integrated contract
    function getIntegratedContract(string calldata contractType) external view returns (address) {
        return integratedContracts[contractType];
    }

    // Functions to interact with specific contracts

    // Function to stake tokens
    function stakeTokens(uint256 amount) external {
        address stakingContract = integratedContracts["BitHelpingStaking"];
        require(stakingContract != address(0), "Staking contract not set");
        require(bithToken.transferFrom(msg.sender, stakingContract, amount), "Token transfer failed");
        emit TokensStaked(msg.sender, amount);
    }

    // Function to burn tokens
    function burnTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        bool success = bithToken.burnTokens(amount); // Ensure burnTokens returns a bool
        require(success, "Burn failed");
        emit TokensBurned(msg.sender, amount);
    }

    // Function to migrate tokens
    function migrateTokens(address recipient, uint256 amount) external {
        address migrationContract = integratedContracts["TokenMigration"];
        require(migrationContract != address(0), "Migration contract not set");
        bool success = bithToken.migrateTokens(recipient, amount); // Call migrateTokens
        require(success, "Migration failed");
        emit TokensMigrated(recipient, amount);
    }

    // Function to collect transaction fees
    function collectTransactionFee(address payer, uint256 amount) external {
        address tariffContract = integratedContracts["tariffManagement"];
        require(tariffContract != address(0), "Tariff contract not set");
        require(bithToken.transferFrom(payer, tariffContract, amount), "Fee transfer failed");
        emit FeeCollected(payer, amount);
    }

    // Pause all operations
    function pauseAll() external onlyOwner {
        require(!bithToken.isPaused(), "Contract already paused");
        bithToken.pause();
        emit ContractPaused(msg.sender);
    }

    // Resume all operations
    function unpauseAll() external onlyOwner {
        require(bithToken.isPaused(), "Contract is not paused");
        bithToken.unpause();
        emit ContractUnpaused(msg.sender);
    }
}

