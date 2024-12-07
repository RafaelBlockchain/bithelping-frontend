// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitHelping {
    // Metadatos del token
    string public constant name = "BitHelping";
    string public constant symbol = "BITH";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 210_000_000_000 * 10**uint256(decimals); // 210B tokens
    uint256 public immutable creationTime;

    // Configuración inicial
    uint256 public constant initialNewbornAllocation = 220 * 10**uint256(decimals); // Cambiado a 220 BITH
    uint256 public constant premineCap = (totalSupply * 80) / 100; // 80% del suministro total preminado
    uint256 public totalMinedTokens;
    uint256 public totalAllocatedToNewborns;

    // Ajuste dinámico de minería
    uint256 public miningReward = 21_000 * 10**uint256(decimals);
    uint256 public constant miningRewardReductionInterval = 365 days; // Reducción anual
    uint256 public constant miningRewardReductionFactor = 90; // 90% cada año
    uint256 public lastMiningAdjustment;

    // Estructura para recién nacidos
    struct Newborn {
        uint256 allocation;
        uint256 unlockTime;
        bool registered;
    }

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => Newborn) public newborns;
    mapping(address => bool) public voters; // Direcciones autorizadas para votar en la DAO
    mapping(bytes32 => bool) public verifiedHashes; // Registro de hashes verificados

    address public owner;

    // Eventos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensAllocated(address indexed newborn, uint256 amount, uint256 unlockTime);
    event TokensMined(address indexed miner, uint256 amount);
    event MiningRewardAdjusted(uint256 newReward);

    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender], "Not a voter");
        _;
    }

    constructor() {
        owner = msg.sender;
        creationTime = block.timestamp;

        balances[owner] = premineCap;
        emit Transfer(address(0), owner, premineCap);

        lastMiningAdjustment = block.timestamp;
    }

    // Registro de recién nacidos con verificación descentralizada
    function registerNewborn(address newborn, uint256 birthTimestamp, bytes32 hash) public onlyVoter {
        require(newborn != address(0), "Invalid address");
        require(!newborns[newborn].registered, "Newborn already registered");
        require(totalAllocatedToNewborns < premineCap, "Premine cap reached");
        require(!verifiedHashes[hash], "Hash already verified"); // Evitar duplicados

        uint256 currentAllocation = calculateNewbornAllocation();
        require(totalAllocatedToNewborns + currentAllocation <= premineCap, "Premine cap exceeded");

        uint256 unlockTime = birthTimestamp + 18 * 365 days;
        newborns[newborn] = Newborn({
            allocation: currentAllocation,
            unlockTime: unlockTime,
            registered: true
        });

        totalAllocatedToNewborns += currentAllocation;
        verifiedHashes[hash] = true;

        emit TokensAllocated(newborn, currentAllocation, unlockTime);
    }

    // Ajuste dinámico de recompensas de minería
    function adjustMiningReward() internal {
        uint256 timeElapsed = block.timestamp - lastMiningAdjustment;

        if (timeElapsed >= miningRewardReductionInterval) {
            miningReward = (miningReward * miningRewardReductionFactor) / 100; // Reducir recompensa
            lastMiningAdjustment = block.timestamp;

            emit MiningRewardAdjusted(miningReward);
        }
    }

    // Función de minería
    function mineTokens() public returns (bool) {
        adjustMiningReward(); // Ajustar la recompensa si es necesario

        require(totalMinedTokens + miningReward <= (totalSupply - premineCap), "Mining cap reached");

        balances[msg.sender] += miningReward;
        totalMinedTokens += miningReward;

        emit TokensMined(msg.sender, miningReward);
        return true;
    }

    // Registro automático de votantes
    function addVoter(address voter) public onlyOwner {
        require(voter != address(0), "Invalid address");
        voters[voter] = true;
    }

    function removeVoter(address voter) public onlyOwner {
        require(voters[voter], "Voter not found");
        voters[voter] = false;
    }

    // Cálculo de asignación para recién nacidos
    function calculateNewbornAllocation() public view returns (uint256) {
        uint256 yearsSinceCreation = (block.timestamp - creationTime) / 365 days;
        uint256 allocation = initialNewbornAllocation;

        for (uint256 i = 0; i < yearsSinceCreation; i++) {
            allocation /= 2;
        }

        return allocation;
    }

    // Funciones estándar de transferencia, aprobación, etc.
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Invalid address");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }
}

