// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BitHelpingLegalCompliance
 * @dev Contract to ensure compliance with legal requirements for the BitHelping platform.
 */
contract BitHelpingLegalCompliance {
    address public owner;

    // Mappings
    mapping(address => bool) private approvedEntities; // Entities approved to interact with the platform
    mapping(address => bool) private blacklistedAddresses; // Addresses blacklisted for regulatory reasons

    // Events
    event EntityApproved(address indexed entity);
    event EntityRemoved(address indexed entity);
    event AddressBlacklisted(address indexed account);
    event AddressRemovedFromBlacklist(address indexed account);
    event LegalActionLogged(address indexed account, string action, uint256 timestamp);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!blacklistedAddresses[account], "Address is blacklisted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Approves an entity to interact with the platform.
     * @param entity The address of the entity to approve.
     */
    function approveEntity(address entity) external onlyOwner {
        require(entity != address(0), "Invalid address");
        approvedEntities[entity] = true;
        emit EntityApproved(entity);
    }

    /**
     * @dev Removes an entity from the approved list.
     * @param entity The address of the entity to remove.
     */
    function removeEntity(address entity) external onlyOwner {
        require(approvedEntities[entity], "Entity not approved");
        approvedEntities[entity] = false;
        emit EntityRemoved(entity);
    }

    /**
     * @dev Blacklists an address, preventing it from interacting with the platform.
     * @param account The address to blacklist.
     */
    function blacklistAddress(address account) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(!blacklistedAddresses[account], "Address already blacklisted");
        blacklistedAddresses[account] = true;
        emit AddressBlacklisted(account);
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param account The address to remove from the blacklist.
     */
    function removeFromBlacklist(address account) external onlyOwner {
        require(blacklistedAddresses[account], "Address not blacklisted");
        blacklistedAddresses[account] = false;
        emit AddressRemovedFromBlacklist(account);
    }

    /**
     * @dev Checks if an address is approved.
     * @param entity The address to check.
     * @return True if the address is approved, false otherwise.
     */
    function isEntityApproved(address entity) external view returns (bool) {
        return approvedEntities[entity];
    }

    /**
     * @dev Checks if an address is blacklisted.
     * @param account The address to check.
     * @return True if the address is blacklisted, false otherwise.
     */
    function isAddressBlacklisted(address account) external view returns (bool) {
        return blacklistedAddresses[account];
    }

    /**
     * @dev Logs legal actions related to an address.
     * @param account The address involved in the legal action.
     * @param action A description of the legal action.
     */
    function logLegalAction(address account, string calldata action) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(bytes(action).length > 0, "Action description required");
        emit LegalActionLogged(account, action, block.timestamp);
    }

    /**
     * @dev Transfers ownership of the contract to a new owner.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}

