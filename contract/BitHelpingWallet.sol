// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBitHelping {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function claimTokens() external;
    function newborns(address account) external view returns (
        uint256 allocation, 
        uint256 unlockTime, 
        bool registered
    );
}

contract BitHelpingWallet {
    address public immutable bitHelping; // Address of the BitHelping contract
    address public owner; // Owner of the wallet (represents the newborn or their guardian)
    address public newborn; // Address of the newborn
    uint256 public unlockTime; // Date when the tokens will be unlocked

    mapping(address => uint256) private ethBalances; // Balances for ETH deposits

    // Events
    event TokensWithdrawn(address indexed by, uint256 amount);
    event TokensTransferred(address indexed to, uint256 amount);
    event WalletOwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyAfterUnlock() {
        require(block.timestamp >= unlockTime, "Tokens are still locked");
        _;
    }

    constructor(address _bitHelping, address _newborn) {
        require(_bitHelping != address(0), "Invalid BitHelping address");
        require(_newborn != address(0), "Invalid newborn address");

        bitHelping = _bitHelping;
        newborn = _newborn;
        owner = msg.sender;

        // Retrieve unlock time from BitHelping
        (, uint256 _unlockTime, bool registered) = IBitHelping(bitHelping).newborns(_newborn);
        require(registered, "Newborn not registered in BitHelping");
        unlockTime = _unlockTime;
    }

    // Check the current balance in BitHelping
    function tokenBalance() public view returns (uint256) {
        return IBitHelping(bitHelping).balanceOf(address(this));
    }

    // Claim tokens from BitHelping to the wallet
    function claimTokens() public onlyOwner onlyAfterUnlock {
        IBitHelping(bitHelping).claimTokens();
    }

    // Transfer tokens from the wallet to another address
    function transferTokens(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(tokenBalance() >= amount, "Insufficient balance");

        // Token transfer via the BitHelping contract
        bool success = IBitHelping(bitHelping).transfer(to, amount);
        require(success, "Token transfer failed");

        emit TokensTransferred(to, amount);
    }

    // Change the wallet owner (e.g., in case of a legal guardian change)
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        emit WalletOwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Deposit ETH into the wallet
    function depositETH() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        ethBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw ETH from the wallet
    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        ethBalances[owner] -= amount;
        payable(owner).transfer(amount);
        emit Withdraw(owner, amount);
    }

    // Check the ETH balance of the contract
    function getContractETHBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Fallback to reject direct ETH transfers
    receive() external payable {
        revert("Direct ETH not accepted");
    }
}
