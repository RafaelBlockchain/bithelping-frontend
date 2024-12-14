// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;

// Interfaz para interactuar con el token BEP-20 BHELP
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract BitHelpingStaking {
    IBHELP public bhelpToken;
    address public owner;

    // Estructura para almacenar la información de cada usuario
    struct Staker {
        uint256 stakedAmount;  // Tokens depositados
        uint256 rewardDebt;    // Recompensas acumuladas
        uint256 lastStakeTime; // Último tiempo de staking
    }

    mapping(address => Staker) public stakers;
    uint256 public rewardRate = 100; // Tasa de recompensa en BHELP por bloque (ajustable)
    uint256 public totalStaked; // Total de tokens depositados
    uint256 public totalRewards; // Total de recompensas acumuladas

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bhelpToken) {
        require(_bhelpToken != address(0), "Invalid token address");
        bhelpToken = IBHELP(_bhelpToken);
        owner = msg.sender;
    }

    // Función para hacer staking (depositar tokens)
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(bhelpToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        Staker storage staker = stakers[msg.sender];
        updateReward(msg.sender);

        staker.stakedAmount += amount;
        staker.lastStakeTime = block.timestamp;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    // Función para hacer unstake (retirar tokens)
    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        Staker storage staker = stakers[msg.sender];
        require(staker.stakedAmount >= amount, "Insufficient staked balance");

        updateReward(msg.sender);

        staker.stakedAmount -= amount;
        totalStaked -= amount;

        require(bhelpToken.transfer(msg.sender, amount), "Transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    // Función para reclamar recompensas acumuladas
    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint256 reward = calculateReward(msg.sender);

        require(reward > 0, "No rewards to claim");

        staker.rewardDebt = reward;
        totalRewards += reward;

        require(bhelpToken.transfer(msg.sender, reward), "Transfer failed");

        emit Claimed(msg.sender, reward);
    }

    // Función interna para actualizar las recompensas acumuladas
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

    // Cambiar la tasa de recompensa (solo propietario)
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    // Consultar el total de tokens depositados
    function totalStakedBalance() external view returns (uint256) {
        return totalStaked;
    }

    // Consultar el total de recompensas acumuladas
    function totalAccumulatedRewards() external view returns (uint256) {
        return totalRewards;
    }
}

