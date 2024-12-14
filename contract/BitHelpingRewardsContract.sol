// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz del token BHELP (BEP20)
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingRewardsContract {
    address public owner;
    IBHELP public bhelpToken;

    // Estructura para almacenar las recompensas pendientes de cada usuario
    mapping(address => uint256) public rewards;
    
    // Estado de la distribución de recompensas (activa o pausada)
    bool public rewardsActive;

    // Eventos para el seguimiento de las recompensas
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsAdded(address indexed user, uint256 amount);
    event RewardsPaused();
    event RewardsResumed();

    // Modificador que asegura que solo el propietario pueda ejecutar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    // Modificador para asegurar que las recompensas estén activas
    modifier rewardsEnabled() {
        require(rewardsActive, "Rewards are not active");
        _;
    }

    // Constructor
    constructor(address _bhelpToken) {
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
        rewardsActive = true; // Las recompensas están activas por defecto
    }

    // Función para agregar recompensas a un usuario
    function addRewards(address user, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        rewards[user] += amount;
        emit RewardsAdded(user, amount);
    }

    // Función para que los usuarios reclamen sus recompensas
    function claimRewards() external rewardsEnabled {
        uint256 rewardAmount = rewards[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");

        // Transferir las recompensas al usuario
        rewards[msg.sender] = 0;
        bhelpToken.transfer(msg.sender, rewardAmount);

        emit RewardsClaimed(msg.sender, rewardAmount);
    }

    // Función para pausar la distribución de recompensas
    function pauseRewards() external onlyOwner {
        rewardsActive = false;
        emit RewardsPaused();
    }

    // Función para reanudar la distribución de recompensas
    function resumeRewards() external onlyOwner {
        rewardsActive = true;
        emit RewardsResumed();
    }

    // Función para que el propietario retire los tokens BHELP del contrato
    function withdrawBHELP(uint256 amount) external onlyOwner {
        uint256 currentBalance = bhelpToken.balanceOf(address(this));
        require(currentBalance >= amount, "Insufficient contract balance");
        bhelpToken.transfer(owner, amount);
    }

    // Función para verificar el saldo de recompensas de un usuario
    function getRewardBalance(address user) external view returns (uint256) {
        return rewards[user];
    }
}

