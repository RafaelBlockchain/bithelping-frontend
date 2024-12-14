// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface for the BHELP token, defining its essential functions.
 */
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external;
    function burnTokens(uint256 amount) external returns (bool);
    function pause() external;
    function unpause() external;
    function isPaused() external view returns (bool);
    function migrateTokens(address recipient, uint256 amount) external returns (bool);
}

/**
 * @title BHELPToken
 * @dev Implementation of the IBHELP interface.
 */
contract BHELPToken is IBHELP {
    string public name = "BitHelping Token";
    string public symbol = "BHELP";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    bool private paused = false;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        mint(owner, initialSupply);
    }

    // Implementación de funciones de la interfaz IBHELP
    function transfer(address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override whenNotPaused returns (bool) {
        require(sender != address(0), "Invalid sender");
        require(recipient != address(0), "Invalid recipient");
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address to, uint256 amount) public override onlyOwner whenNotPaused {
        require(to != address(0), "Invalid address");
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burnTokens(uint256 amount) external override whenNotPaused returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function pause() external override onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external override onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() external view override returns (bool) {
        return paused;
    }

    function migrateTokens(address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(recipient != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Eventos requeridos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Paused(address indexed account);
    event Unpaused(address indexed account);
}


