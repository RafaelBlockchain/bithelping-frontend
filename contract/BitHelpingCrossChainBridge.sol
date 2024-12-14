// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;

// Interface for the BHELP token (BEP20)
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function mint(address recipient, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

contract BitHelpingCrossChainBridge {
    address public owner;
    IBHELP public bhelpToken;
    mapping(address => uint256) public pendingTransfers;

    // Events to log cross-chain transfers
    event TransferInitiated(address indexed from, address indexed to, uint256 amount, uint256 chainId);
    event TransferCompleted(address indexed from, address indexed to, uint256 amount, uint256 chainId);

    // Modifiers to ensure only the contract owner can perform certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor
    constructor(address _bhelpToken) {
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    // Initiate a cross-chain transfer to another chain
    function initiateCrossChainTransfer(address to, uint256 amount, uint256 targetChainId) external {
        require(bhelpToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > 0, "Amount must be greater than zero");

        // Burn the tokens on the current chain
        bhelpToken.burn(msg.sender, amount);

        // Register the transfer
        pendingTransfers[to] += amount;

        // Emit transfer initiated event
        emit TransferInitiated(msg.sender, to, amount, targetChainId);
    }

    // Complete the transfer on the destination chain (this must be called by a validator or trusted entity)
    function completeCrossChainTransfer(address from, address to, uint256 amount, uint256 sourceChainId) external onlyOwner {
        require(pendingTransfers[from] >= amount, "No pending transfer for this address");
        
        // Mint the tokens on the destination chain (could be another token contract on BSC, Polygon, etc.)
        bhelpToken.mint(to, amount);
        
        // Update the pending transfers balance
        pendingTransfers[from] -= amount;

        // Emit transfer completed event
        emit TransferCompleted(from, to, amount, sourceChainId);
    }

    // Emergency function for the owner to withdraw BHELP tokens from the contract
    function withdrawBHELP(uint256 amount) external onlyOwner {
        require(bhelpToken.transfer(owner, amount), "Transfer failed");
    }
}

