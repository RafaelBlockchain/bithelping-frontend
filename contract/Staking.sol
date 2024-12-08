// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BithHelpingStaking {
    IBITH public bithToken;
    address public owner;

    // Estructura para almacenar datos de cada usuario
    struct Staker {
        uint256 stakedAmount;  // Tokens en staking
        uint256 rewardDebt;    // Deuda de recompensa acumulada
        uint256 lastStakeTime; // Último tiempo de staking
    }

    mapping(address => Staker) public stakers;
    uint256 public rewardRate = 100; // Tasa de recompensa en BITH por bloque (puede ajustarse)
    uint256 public totalStaked; // Total de tokens en staking
    uint256 public totalRewards; // Recompensas totales acumuladas

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        bithToken = IBITH(_bithToken);
        owner = msg.sender;
    }

    // Función para realizar staking (depositar tokens)
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        Staker storage staker = stakers[msg.sender];
        updateReward(msg.sender);

        staker.stakedAmount += amount;
        staker.lastStakeTime = block.timestamp;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    // Función para realizar unstake (retirar tokens)
    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        Staker storage staker = stakers[msg.sender];
        require(staker.stakedAmount >= amount, "Insufficient staked balance");

        updateReward(msg.sender);

        staker.stakedAmount -= amount;
        totalStaked -= amount;

        require(bithToken.transfer(msg.sender, amount), "Transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    // Función para reclamar las recompensas acumuladas
    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint256 reward = calculateReward(msg.sender);

        require(reward > 0, "No rewards to claim");

        staker.rewardDebt = reward;
        totalRewards += reward;

        require(bithToken.transfer(msg.sender, reward), "Transfer failed");

        emit Claimed(msg.sender, reward);
    }

    // Función interna para actualizar la recompensa acumulada
    function updateReward(address user) internal {
        Staker storage staker = stakers[user];
        uint256 reward = calculateReward(user);

        staker.rewardDebt = reward;
        staker.lastStakeTime = block.timestamp;
    }

    // Función interna para calcular las recompensas
    function calculateReward(address user) internal view returns (uint256) {
        Staker storage staker = stakers[user];
        uint256 stakedDuration = block.timestamp - staker.lastStakeTime;
        uint256 reward = (stakedDuration / 1 days) * rewardRate * staker.stakedAmount;
        return reward + staker.rewardDebt;
    }

    // Función para consultar el saldo de staking de un usuario
    function stakedBalance(address user) external view returns (uint256) {
        return stakers[user].stakedAmount;
    }

    // Función para consultar las recompensas acumuladas de un usuario
    function pendingRewards(address user) external view returns (uint256) {
        return calculateReward(user);
    }

    // Cambiar la tasa de recompensas (solo propietario)
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    // Consultar el total de tokens en staking
    function totalStakedBalance() external view returns (uint256) {
        return totalStaked;
    }

    // Consultar las recompensas totales acumuladas
    function totalAccumulatedRewards() external view returns (uint256) {
        return totalRewards;
    }
}

