// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TreasuryContract
 * @dev This contract manages the treasury for BitHelping (BHELP).
 */
contract TreasuryContract {
    address public owner;
    mapping(address => bool) public authorized;
    uint256 public totalFunds;

    event FundsDeposited(address indexed from, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 amount);
    event AuthorizedAdded(address indexed account);
    event AuthorizedRemoved(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Deposit funds into the treasury.
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        totalFunds += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw funds from the treasury.
     * @param to The address to send the funds.
     * @param amount The amount to withdraw.
     */
    function withdraw(address payable to, uint256 amount) external onlyAuthorized {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= totalFunds, "Insufficient funds");

        totalFunds -= amount;
        to.transfer(amount);
        emit FundsWithdrawn(to, amount);
    }

    /**
     * @dev Add an authorized address.
     * @param account The address to authorize.
     */
    function addAuthorized(address account) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(!authorized[account], "Already authorized");

        authorized[account] = true;
        emit AuthorizedAdded(account);
    }

    /**
     * @dev Remove an authorized address.
     * @param account The address to deauthorize.
     */
    function removeAuthorized(address account) external onlyOwner {
        require(authorized[account], "Address not authorized");

        authorized[account] = false;
        emit AuthorizedRemoved(account);
    }

    /**
     * @dev Get the balance of the treasury.
     * @return The current balance of the treasury.
     */
    function getTreasuryBalance() external view returns (uint256) {
        return totalFunds;
    }
}

