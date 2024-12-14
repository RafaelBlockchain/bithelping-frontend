// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BitHelpingHalving
 * @dev Implements halving mechanisms for mining rewards and newborn rewards in the BHELP ecosystem.
 */
contract BitHelpingHalving {
    address public owner; // Owner of the contract

    // Mining rewards
    uint256 public miningInitialReward; // Initial reward for mining a block
    uint256 public miningHalvingInterval; // Number of blocks between mining halvings
    uint256 public currentMiningReward; // Current mining reward
    uint256 public totalBlocksMined; // Total blocks mined so far
    uint256 public lastMiningHalvingBlock; // Block number when the last mining halving occurred

    // Newborn rewards
    uint256 public newbornInitialReward; // Initial reward for newborn entities
    uint256 public newbornHalvingInterval; // Number of newborns between halvings
    uint256 public currentNewbornReward; // Current newborn reward
    uint256 public totalNewborns; // Total newborns registered so far
    uint256 public lastNewbornHalving; // Count when the last newborn halving occurred

    // Events
    event BlockMined(address indexed miner, uint256 reward, uint256 blockNumber);
    event RewardHalved(string rewardType, uint256 oldReward, uint256 newReward, uint256 referencePoint);
    event NewbornRewarded(address indexed recipient, uint256 reward, uint256 totalNewborns);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    constructor(
        uint256 _miningInitialReward,
        uint256 _miningHalvingInterval,
        uint256 _newbornInitialReward,
        uint256 _newbornHalvingInterval
    ) {
        require(_miningInitialReward > 0, "Mining reward must be greater than zero");
        require(_miningHalvingInterval > 0, "Mining halving interval must be greater than zero");
        require(_newbornInitialReward > 0, "Newborn reward must be greater than zero");
        require(_newbornHalvingInterval > 0, "Newborn halving interval must be greater than zero");

        owner = msg.sender;

        // Initialize mining reward system
        miningInitialReward = _miningInitialReward; // 600,000 BHELP
        miningHalvingInterval = _miningHalvingInterval; // E.g., 100,000 blocks
        currentMiningReward = _miningInitialReward;
        lastMiningHalvingBlock = 0;

        // Initialize newborn reward system
        newbornInitialReward = _newbornInitialReward; // 4100 BHELP
        newbornHalvingInterval = _newbornHalvingInterval; // E.g., 1,000,000 newborns
        currentNewbornReward = _newbornInitialReward;
        lastNewbornHalving = 0;
    }

    /**
     * @dev Mines a block and assigns the reward to the miner.
     * Automatically handles halving if the block interval is reached.
     * @param miner The address of the miner receiving the reward.
     */
    function mineBlock(address miner) external onlyOwner {
        require(miner != address(0), "Invalid miner address");

        totalBlocksMined++; // Increment total blocks mined

        // Check if a mining halving is due
        if (totalBlocksMined >= lastMiningHalvingBlock + miningHalvingInterval) {
            _halveMiningReward();
        }

        // Reward the miner
        emit BlockMined(miner, currentMiningReward, totalBlocksMined);
    }

    /**
     * @dev Registers a newborn and assigns the reward to the recipient.
     * Automatically handles halving if the newborn interval is reached.
     * @param recipient The address of the recipient receiving the newborn reward.
     */
    function rewardNewborn(address recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");

        totalNewborns++; // Increment total newborn count

        // Check if a newborn halving is due
        if (totalNewborns >= lastNewbornHalving + newbornHalvingInterval) {
            _halveNewbornReward();
        }

        // Reward the newborn
        emit NewbornRewarded(recipient, currentNewbornReward, totalNewborns);
    }

    /**
     * @dev Performs the halving of the mining reward.
     */
    function _halveMiningReward() internal {
        uint256 oldReward = currentMiningReward;
        currentMiningReward = currentMiningReward / 2; // Halve the reward
        lastMiningHalvingBlock = totalBlocksMined; // Update the last mining halving block

        emit RewardHalved("Mining", oldReward, currentMiningReward, totalBlocksMined);
    }

    /**
     * @dev Performs the halving of the newborn reward.
     */
    function _halveNewbornReward() internal {
        uint256 oldReward = currentNewbornReward;
        currentNewbornReward = currentNewbornReward / 2; // Halve the reward
        lastNewbornHalving = totalNewborns; // Update the last newborn halving count

        emit RewardHalved("Newborn", oldReward, currentNewbornReward, totalNewborns);
    }

    /**
     * @dev Fetches the current rewards and next halving info.
     * @return miningReward The current mining reward.
     * @return blocksToMiningHalving Remaining blocks until the next mining halving.
     * @return newbornReward The current newborn reward.
     * @return newbornsToHalving Remaining newborns until the next newborn halving.
     */
    function getRewardInfo()
        external
        view
        returns (
            uint256 miningReward,
            uint256 blocksToMiningHalving,
            uint256 newbornReward,
            uint256 newbornsToHalving
        )
    {
        miningReward = currentMiningReward;
        blocksToMiningHalving = (lastMiningHalvingBlock + miningHalvingInterval) - totalBlocksMined;

        newbornReward = currentNewbornReward;
        newbornsToHalving = (lastNewbornHalving + newbornHalvingInterval) - totalNewborns;
    }
}

