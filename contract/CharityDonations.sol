// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CharityDonations {
    address public owner;
    IBITH public bithToken;
    uint256 public totalDonations;

    struct Beneficiary {
        string name;
        address wallet;
        uint256 totalReceived;
        bool exists;
    }

    mapping(address => Beneficiary) public beneficiaries;
    address[] public beneficiaryList;

    event DonationReceived(address indexed donor, uint256 amount);
    event FundsDistributed(address indexed beneficiary, uint256 amount);
    event BeneficiaryAdded(address indexed wallet, string name);
    event BeneficiaryRemoved(address indexed wallet, string name);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Donar tokens BITH al contrato
    function donate(uint256 amount) external {
        require(amount > 0, "Donation amount must be greater than 0");
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        totalDonations += amount;
        emit DonationReceived(msg.sender, amount);
    }

    // Agregar un beneficiario para recibir fondos
    function addBeneficiary(address wallet, string calldata name) external onlyOwner {
        require(wallet != address(0), "Invalid wallet address");
        require(!beneficiaries[wallet].exists, "Beneficiary already exists");

        beneficiaries[wallet] = Beneficiary({
            name: name,
            wallet: wallet,
            totalReceived: 0,
            exists: true
        });
        beneficiaryList.push(wallet);

        emit BeneficiaryAdded(wallet, name);
    }

    // Eliminar un beneficiario
    function removeBeneficiary(address wallet) external onlyOwner {
        require(beneficiaries[wallet].exists, "Beneficiary does not exist");

        string memory name = beneficiaries[wallet].name;
        delete beneficiaries[wallet];

        // Remove wallet from beneficiaryList
        for (uint256 i = 0; i < beneficiaryList.length; i++) {
            if (beneficiaryList[i] == wallet) {
                beneficiaryList[i] = beneficiaryList[beneficiaryList.length - 1];
                beneficiaryList.pop();
                break;
            }
        }

        emit BeneficiaryRemoved(wallet, name);
    }

    // Distribuir fondos a un beneficiario
    function distributeFunds(address wallet, uint256 amount) external onlyOwner {
        require(beneficiaries[wallet].exists, "Beneficiary does not exist");
        require(amount > 0, "Amount must be greater than 0");
        require(bithToken.balanceOf(address(this)) >= amount, "Insufficient funds");

        require(bithToken.transfer(wallet, amount), "Token transfer failed");

        beneficiaries[wallet].totalReceived += amount;
        emit FundsDistributed(wallet, amount);
    }

    // Obtener la lista de beneficiarios
    function getBeneficiaries() external view returns (address[] memory) {
        return beneficiaryList;
    }

    // Retirar accidentalmente enviados tokens al contrato (solo por el owner)
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(bithToken.balanceOf(address(this)) >= amount, "Insufficient funds");

        require(bithToken.transfer(owner, amount), "Token transfer failed");
    }
}

