// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBHELP.sol"; // Ensure the correct import path

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title BHELP Token
 * @dev Implementation of the BHELP token with pause and minting capabilities.
 */
contract BHELP is ERC20, Ownable, Pausable, IBHELP {
    constructor() ERC20("BHELP Token", "BHELP") {}

    /**
     * @dev Transfer tokens from one address to another.
     * @param sender The address from which tokens will be sent.
     * @param recipient The address to receive the tokens.
     * @param amount The number of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Mints new tokens to a specified address.
     * @param to The address to receive the newly minted tokens.
     * @param amount The number of tokens to mint.
     */
    function mint(address to, uint256 amount) external override onlyOwner whenNotPaused {
        _mint(to, amount);
    }

    /**
     * @dev Burns a specified amount of tokens from the caller's account.
     * @param amount The number of tokens to burn.
     * @return A boolean indicating whether the operation succeeded.
     */
    function burnTokens(uint256 amount) external override whenNotPaused returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    /**
     * @dev Pauses all token transfers and minting operations. Only callable by the contract owner.
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @dev Resumes all token operations after a pause. Only callable by the contract owner.
     */
    function unpause() external override onlyOwner {
        _unpause();
    }

    /**
     * @dev Checks whether the contract is currently paused.
     * @return A boolean indicating whether the contract is paused.
     */
    function isPaused() external view override returns (bool) {
        return paused();
    }

    /**
     * @dev Migrates a specified amount of tokens to a new address.
     * @param recipient The address to receive the migrated tokens.
     * @param amount The number of tokens to migrate.
     * @return A boolean indicating whether the operation succeeded.
     */
    function migrateTokens(address recipient, uint256 amount) external override onlyOwner whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}


