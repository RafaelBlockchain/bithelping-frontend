// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function getOwner() external view returns (address);
}

contract BitHelpingBHELP is IBEP20 {
    // Variables principales
    string public name = "BitHelping";
    string public symbol = "BHELP";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;
    address public feeRecipient;
    uint256 public transactionFee = 180; // 1.8% (representado en base 10,000)
    mapping(address => bool) public isFeeExempt;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Eventos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensBurned(address indexed account, uint256 amount);
    event TokensStaked(address indexed staker, uint256 amount);
    event TokensClaimed(address indexed staker, uint256 reward);
    event Migration(address indexed user, uint256 amount);
    event Paused();
    event Unpaused();

    // Constantes
    address public constant predefinedAddress = 0xb8A00E1424ca700f922F789219E0E09aa811F067; // Dirección predefinida
    uint256 public constant predefinedAmount = 10000000000000000000000000000; // Monto predefinido (1000000 tokens con 18 decimales)

    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // Pausable functionality
    bool public paused = false;

    // Staking variables
    struct Stake {
        uint256 amount;
        uint256 reward;
    }

    mapping(address => Stake) public stakes;
    uint256 public stakingRewardRate = 100; // Representa 1% de recompensa

    constructor(uint256 _initialSupply, address _feeRecipient) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** decimals);
        balances[owner] = totalSupply;
        feeRecipient = _feeRecipient;
        isFeeExempt[owner] = true;
        emit Transfer(address(0), owner, totalSupply);
    }

    // Pausable functions
    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }

    // BEP20 functionality
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override whenNotPaused returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) external view override returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(balances[sender] >= amount, "Insufficient balance");

        uint256 fee = 0;
        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            fee = (amount * transactionFee) / 10000;
            balances[feeRecipient] += fee;
        }

        balances[sender] -= amount;
        balances[recipient] += (amount - fee);

        emit Transfer(sender, recipient, amount - fee);
        if (fee > 0) {
            emit Transfer(sender, feeRecipient, fee);
        }
    }

    // Staking functionality
    function stakeTokens(uint256 amount) external whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        stakes[msg.sender].amount += amount;
        stakes[msg.sender].reward += (amount * stakingRewardRate) / 10000;

        emit TokensStaked(msg.sender, amount);
    }

    function claimStakingRewards() external whenNotPaused {
        uint256 reward = stakes[msg.sender].reward;
        require(reward > 0, "No rewards to claim");

        stakes[msg.sender].reward = 0;
        balances[msg.sender] += reward;

        emit TokensClaimed(msg.sender, reward);
    }

    // Token burning functionality
    function burnTokens(uint256 amount) external whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit TokensBurned(msg.sender, amount);
    }

    // Token migration functionality
    function migrateTokens(address recipient, uint256 amount) external whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Migration(msg.sender, amount);
    }

    // Fee management
    function setTransactionFee(uint256 _fee) external onlyOwner {
        require(_fee <= 500, "Fee cannot exceed 5%");
        transactionFee = _fee;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "Invalid fee recipient address");
        feeRecipient = _feeRecipient;
    }

    function exemptFromFees(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
    }
}


