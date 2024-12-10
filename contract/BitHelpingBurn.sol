// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface IBITH {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
}

contract BitHelpingBurn {
    address public owner;
    IBITH public bithToken;

    event TokensBurned(address indexed burner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    /**
     * @dev Allows the owner to burn tokens from the contract.
     * @param amount The amount of tokens to burn.
     */
    function ownerBurn(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.balanceOf(address(this)) >= amount, "Insufficient tokens in contract");

        bithToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Allows users to burn their own tokens.
     * @param amount The amount of tokens to burn.
     */
    function userBurn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Transfer tokens to the contract to burn
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Burn the tokens from the contract
        bithToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Allows transferring tokens to the contract to burn them manually.
     * Only the owner can execute this function.
     * @param amount The amount of tokens to transfer to the contract to be burned.
     */
    function fundBurnPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    /**
     * @dev Returns the current balance of tokens stored in the contract to be burned.
     * @return The token balance.
     */
    function getBurnPoolBalance() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }
}
