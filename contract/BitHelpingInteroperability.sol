// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Interoperability Contract for BitHelping
 * @dev Facilitates interactions between BitHelping and external platforms or chains.
 */
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingInteroperability {
    address public owner;
    IBHELP public bhelpToken;

    // Mapping for approved external platforms
    mapping(address => bool) public approvedPlatforms;

    // Events
    event PlatformApproved(address indexed platform);
    event PlatformRevoked(address indexed platform);
    event CrossChainTransferInitiated(address indexed sender, string targetChain, string targetAddress, uint256 amount);
    event OraclesUpdated(address indexed oldOracle, address indexed newOracle);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier onlyApprovedPlatform() {
        require(approvedPlatforms[msg.sender], "Platform not approved");
        _;
    }

    constructor(address _bhelpToken) {
        require(_bhelpToken != address(0), "Invalid BHELP token address");
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    // ======================= Platform Management ======================= //

    /**
     * @dev Approves an external platform for interoperability.
     * @param platform The address of the external platform.
     */
    function approvePlatform(address platform) external onlyOwner {
        require(platform != address(0), "Invalid platform address");
        approvedPlatforms[platform] = true;
        emit PlatformApproved(platform);
    }

    /**
     * @dev Revokes approval for an external platform.
     * @param platform The address of the external platform.
     */
    function revokePlatform(address platform) external onlyOwner {
        require(approvedPlatforms[platform], "Platform is not approved");
        approvedPlatforms[platform] = false;
        emit PlatformRevoked(platform);
    }

    // ======================= Cross-Chain Operations ======================= //

    /**
     * @dev Initiates a cross-chain transfer by locking tokens in the contract.
     * @param targetChain The target blockchain (e.g., "Ethereum", "Binance Smart Chain").
     * @param targetAddress The recipient address on the target blockchain.
     * @param amount The amount of tokens to transfer.
     */
    function initiateCrossChainTransfer(
        string calldata targetChain,
        string calldata targetAddress,
        uint256 amount
    ) external {
        require(bytes(targetChain).length > 0, "Target chain is required");
        require(bytes(targetAddress).length > 0, "Target address is required");
        require(amount > 0, "Amount must be greater than zero");
        
        // Lock tokens in the contract
        require(
            bhelpToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        emit CrossChainTransferInitiated(msg.sender, targetChain, targetAddress, amount);
    }

    /**
     * @dev Releases tokens to the recipient after confirmation from an oracle.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to release.
     */
    function releaseTokens(address recipient, uint256 amount) external onlyApprovedPlatform {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");

        // Transfer tokens to the recipient
        require(bhelpToken.transfer(recipient, amount), "Token transfer failed");
    }

    // ======================= Oracle Management ======================= //

    address public oracle;

    /**
     * @dev Updates the oracle address.
     * @param newOracle The address of the new oracle.
     */
    function updateOracle(address newOracle) external onlyOwner {
        require(newOracle != address(0), "Invalid oracle address");
        address oldOracle = oracle;
        oracle = newOracle;
        emit OraclesUpdated(oldOracle, newOracle);
    }

    /**
     * @dev Validates cross-chain operations using the oracle.
     * @param data The data from the oracle (e.g., proof of transaction on the other chain).
     */
    function validateCrossChainOperation(bytes calldata data) external view returns (bool) {
        // Placeholder for oracle validation logic
        // Implement actual oracle interaction
        return true; // Assume always valid for now
    }

    // ======================= Token Management ======================= //

    /**
     * @dev Withdraws tokens from the contract to the owner's address.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bhelpToken.transfer(owner, amount), "Token withdrawal failed");
    }

    // ======================= Emergency Functions ======================= //

    /**
     * @dev Allows the owner to recover mistakenly sent tokens.
     * @param tokenAddress The address of the token to recover.
     * @param amount The amount of tokens to recover.
     */
    function recoverTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than zero");

        IBHELP token = IBHELP(tokenAddress);
        require(token.transfer(owner, amount), "Token recovery failed");
    }
}

