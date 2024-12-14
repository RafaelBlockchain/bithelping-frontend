// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BHELP Token
 * @dev BEP20 token implementation for the BitHelping platform.
 */
contract BHELPToken {
    string public name = "BitHelping Token";
    string public symbol = "BHELP";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    bool private paused = false;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Events required by BEP20
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(owner, initialSupply); // Mint initial supply to the owner
    }

    // ======================= BEP20 REQUIRED FUNCTIONS ======================= //

    /**
     * @dev Transfers tokens to a specified address.
     * @param recipient The address receiving the tokens.
     * @param amount The amount of tokens to transfer.
     * @return True if the transfer is successful.
     */
    function transfer(address recipient, uint256 amount) external whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Returns the balance of the specified address.
     * @param account The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @dev Approves an address to spend a specified amount of tokens on behalf of the sender.
     * @param spender The address authorized to spend the tokens.
     * @param amount The maximum amount the spender is allowed to spend.
     * @return True if the approval is successful.
     */
    function approve(address spender, uint256 amount) external whenNotPaused returns (bool) {
        require(spender != address(0), "Spender cannot be zero address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Returns the remaining amount a spender is allowed to spend on behalf of an owner.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     * @return The remaining allowance.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }

    /**
     * @dev Transfers tokens on behalf of another address.
     * @param sender The address providing the tokens.
     * @param recipient The address receiving the tokens.
     * @param amount The amount to transfer.
     * @return True if the transfer is successful.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external whenNotPaused returns (bool) {
        require(sender != address(0), "Sender cannot be zero address");
        require(recipient != address(0), "Recipient cannot be zero address");
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    // ======================= CUSTOM FUNCTIONS ======================= //

    /**
     * @dev Mints new tokens.
     * @param to The address receiving the new tokens.
     * @param amount The number of tokens to mint.
     */
    function _mint(address to, uint256 amount) internal onlyOwner {
        require(to != address(0), "Recipient cannot be zero address");
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Burns tokens from the caller's account.
     * @param amount The number of tokens to burn.
     */
    function burn(uint256 amount) external whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    /**
     * @dev Pauses all token operations.
     */
    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Unpauses all token operations.
     */
    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Checks whether the contract is paused.
     * @return True if the contract is paused.
     */
    function isPaused() external view returns (bool) {
        return paused;
    }

    // ======================= INTERNAL FUNCTIONS ======================= //

    /**
     * @dev Internal function to transfer tokens between accounts.
     * @param sender The address providing the tokens.
     * @param recipient The address receiving the tokens.
     * @param amount The amount to transfer.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Sender cannot be zero address");
        require(recipient != address(0), "Recipient cannot be zero address");
        require(balances[sender] >= amount, "Insufficient balance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}

