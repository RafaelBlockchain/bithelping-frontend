// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title RewardsContract
/// @dev This contract allows users to stake tokens, earn rewards over time, and withdraw their stake or claim rewards.
contract RewardsContract is Ownable {
    using SafeERC20 for IERC20;

    // Token used for staking
    IERC20 public stakingToken;

    // Token used for rewards
    IERC20 public rewardsToken;

    // Structure to record a user's staking information
    struct Stake {
        uint256 amount; // Amount of tokens staked
        uint256 rewardDebt; // Pending reward debt
        uint256 lastUpdated; // Last stake update
    }

    // Mapping of users to their stakes
    mapping(address => Stake) public stakes;

    // Rewards per block
    uint256 public rewardsPerBlock;

    // Suggested reward rate (can serve as a reference)
    uint256 public suggestedRewardsRate;

    // Staking event
    event Staked(address indexed user, uint256 amount);

    // Withdrawal event
    event Withdrawn(address indexed user, uint256 amount);

    // Rewards claimed event
    event RewardsClaimed(address indexed user, uint256 reward);

    // Rewards rate update event
    event RewardsRateUpdated(uint256 oldRate, uint256 newRate);

    /// @notice Constructor to initialize the contract
    /// @param _stakingToken The token users will stake
    /// @param _rewardsToken The token used for rewards
    /// @param _rewardsPerBlock Rewards distributed per block
    /// @param _suggestedRewardsRate Suggested rewards rate for reference
    constructor(
        IERC20 _stakingToken, 
        IERC20 _rewardsToken, 
        uint256 _rewardsPerBlock, 
        uint256 _suggestedRewardsRate
    ) Ownable(msg.sender) {
        stakingToken = _stakingToken;
        rewardsToken = _rewardsToken;
        rewardsPerBlock = _rewardsPerBlock;
        suggestedRewardsRate = _suggestedRewardsRate;
    }

    /// @notice Stake tokens to start earning rewards
    /// @param _amount The amount of tokens to stake
    function stake(uint256 _amount) external {
        require(_amount > 0, "Staking amount must be greater than zero.");

        Stake storage userStake = stakes[msg.sender];
        
        // Update pending rewards
        if (userStake.amount > 0) {
            uint256 pendingReward = calculateReward(msg.sender);
            userStake.rewardDebt += pendingReward;
        }

        // Transfer tokens to the contract
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        userStake.amount += _amount;
        userStake.lastUpdated = block.number;

        emit Staked(msg.sender, _amount);
    }

    /// @notice Withdraw staked tokens
    /// @param _amount The amount of tokens to withdraw
    function withdraw(uint256 _amount) external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount >= _amount, "Insufficient staked tokens.");

        // Update pending rewards
        uint256 pendingReward = calculateReward(msg.sender);
        userStake.rewardDebt += pendingReward;

        // Reduce the stake amount and transfer tokens to the user
        userStake.amount -= _amount;
        stakingToken.safeTransfer(msg.sender, _amount);
        userStake.lastUpdated = block.number;

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice Claim accumulated rewards
    function claimRewards() external {
        Stake storage userStake = stakes[msg.sender];

        // Calculate pending rewards
        uint256 reward = calculateReward(msg.sender) + userStake.rewardDebt;
        require(reward > 0, "No rewards to claim.");

        // Transfer rewards to the user
        rewardsToken.safeTransfer(msg.sender, reward);
        userStake.rewardDebt = 0;
        userStake.lastUpdated = block.number;

        emit RewardsClaimed(msg.sender, reward);
    }

    /// @notice Calculate a user's pending rewards
    /// @param _user The user's address
    /// @return The amount of pending rewards
    function calculateReward(address _user) public view returns (uint256) {
        Stake storage userStake = stakes[_user];

        if (userStake.amount == 0) {
            return 0;
        }

        uint256 blocksStaked = block.number - userStake.lastUpdated;
        uint256 pendingReward = (blocksStaked * rewardsPerBlock * userStake.amount) / 1e18;

        return pendingReward;
    }

    /// @notice Update the rewards per block rate
    /// @param _newRate The new rewards rate per block
    function updateRewardsPerBlock(uint256 _newRate) external onlyOwner {
        emit RewardsRateUpdated(rewardsPerBlock, _newRate);
        rewardsPerBlock = _newRate;
    }

    /// @notice Check if the current rate aligns with the suggested rate
    /// @return True if aligned, false otherwise
    function isRateAlignedWithSuggestion() external view returns (bool) {
        return rewardsPerBlock <= suggestedRewardsRate;
    }

    /// @notice Withdraw tokens locked by the contract (owner only)
    /// @param _token The token to withdraw
    /// @param _amount The amount to withdraw
    function emergencyWithdrawTokens(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.safeTransfer(owner(), _amount);
    }
}

