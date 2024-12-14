// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingDistribution {
    address public owner;
    IBHELP public bhelpToken;
    uint256 public constant DISTRIBUTION_AMOUNT = 210 * 10**18; // 210 BHELP (Ensure to adjust decimals)
    mapping(address => bool) public hasReceivedBhelp; // Mapping to ensure each address can receive tokens only once

    event TokensDistributed(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bhelpToken) {
        require(_bhelpToken != address(0), "Invalid BHELP token contract address");
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    // Function to automatically distribute BHELP to registered addresses
    function distributeBhelp(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "There must be at least one address");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(!hasReceivedBhelp[recipient], "This address has already received BHELP");

            uint256 currentBalance = bhelpToken.balanceOf(address(this));
            require(currentBalance >= DISTRIBUTION_AMOUNT, "Insufficient contract balance");

            // Transfer 210 BHELP to each user
            bhelpToken.transfer(recipient, DISTRIBUTION_AMOUNT);
            hasReceivedBhelp[recipient] = true; // Mark as received

            emit TokensDistributed(recipient, DISTRIBUTION_AMOUNT);
        }
    }

    // Function for users to claim their BHELP
    function claimBhelp() external {
        require(!hasReceivedBhelp[msg.sender], "You have already claimed your BHELP allocation");

        uint256 currentBalance = bhelpToken.balanceOf(address(this));
        require(currentBalance >= DISTRIBUTION_AMOUNT, "Insufficient contract balance");

        bhelpToken.transfer(msg.sender, DISTRIBUTION_AMOUNT);
        hasReceivedBhelp[msg.sender] = true; // Mark as received

        emit TokensClaimed(msg.sender, DISTRIBUTION_AMOUNT);
    }

    // Function for the owner to withdraw tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        uint256 currentBalance = bhelpToken.balanceOf(address(this));
        require(currentBalance >= amount, "Insufficient contract balance");
        bhelpToken.transfer(owner, amount);
    }

    // Function to check the token balance in the contract
    function contractBalance() external view returns (uint256) {
        return bhelpToken.balanceOf(address(this));
    }
}

