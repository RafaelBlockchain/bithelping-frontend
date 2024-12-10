// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecurityUpdate {
    address public owner;
    mapping(address => bool) public admins;
    bool public contractPaused;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event ContractPaused(address indexed admin);
    event ContractResumed(address indexed admin);
    event EmergencyUpdate(address indexed updater, string message);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not authorized: Admin only");
        _;
    }

    modifier whenNotPaused() {
        require(!contractPaused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true; // Owner is also an admin by default
        contractPaused = false;
    }

    // Transfer ownership to a new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Add an admin
    function addAdmin(address admin) external onlyOwner {
        require(admin != address(0), "Invalid address");
        require(!admins[admin], "Already an admin");
        admins[admin] = true;
        emit AdminAdded(admin);
    }

    // Remove an admin
    function removeAdmin(address admin) external onlyOwner {
        require(admins[admin], "Not an admin");
        admins[admin] = false;
        emit AdminRemoved(admin);
    }

    // Pause the contract in case of an emergency
    function pauseContract() external onlyAdmin {
        require(!contractPaused, "Contract already paused");
        contractPaused = true;
        emit ContractPaused(msg.sender);
    }

    // Resume the contract after resolving issues
    function resumeContract() external onlyAdmin {
        require(contractPaused, "Contract is not paused");
        contractPaused = false;
        emit ContractResumed(msg.sender);
    }

    // Emergency update for critical messages
    function emergencyUpdate(string calldata message) external onlyAdmin {
        emit EmergencyUpdate(msg.sender, message);
    }

    // Example secure function to demonstrate usage
    function secureFunction() external whenNotPaused onlyAdmin {
        // Implement functionality here
    }
}

