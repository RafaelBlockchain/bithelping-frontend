// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the BEP20 Token (BHELP Token)
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

contract BitHelpingCharityDonations {

    // Token utilizado para realizar las donaciones
    IBHELP public bhelpToken;

    // Dirección del propietario del contrato
    address public owner;

    // Evento que se emite cuando una donación es realizada
    event DonationMade(address indexed donor, uint256 amount, address indexed charity);

    // Mapeo para almacenar los saldos de donaciones por caridad
    mapping(address => uint256) public charityBalances;

    // Estructura para representar una caridad
    struct Charity {
        string name;
        string description;
        address charityAddress;
    }

    // Array de caridades registradas
    Charity[] public charities;

    // Modificador para asegurar que solo el propietario del contrato pueda ejecutar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Only the owner can perform this action");
        _;
    }

    // Constructor para establecer el token BHELP y la dirección del propietario
    constructor(address _bhelpToken) {
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    // Función para registrar una nueva caridad
    function registerCharity(string memory _name, string memory _description, address _charityAddress) external onlyOwner {
        charities.push(Charity({
            name: _name,
            description: _description,
            charityAddress: _charityAddress
        }));
    }

    // Función para realizar una donación a una caridad específica
    function donate(uint256 _charityIndex, uint256 _amount) external {
        require(_charityIndex < charities.length, "Invalid charity index");
        require(bhelpToken.balanceOf(msg.sender) >= _amount, "Insufficient token balance for donation");
        require(_amount > 0, "Donation amount must be greater than zero");

        // Transferir los tokens de la persona donante a la caridad
        bhelpToken.transfer(charities[_charityIndex].charityAddress, _amount);

        // Registrar la donación en el balance de la caridad
        charityBalances[charities[_charityIndex].charityAddress] += _amount;

        // Emitir el evento de la donación
        emit DonationMade(msg.sender, _amount, charities[_charityIndex].charityAddress);
    }

    // Función para obtener la cantidad total de donaciones realizadas a una caridad específica
    function getTotalDonationsToCharity(address _charityAddress) external view returns (uint256) {
        return charityBalances[_charityAddress];
    }

    // Función para retirar tokens del contrato (solo el propietario puede retirar)
    function withdraw(uint256 _amount) external onlyOwner {
        require(bhelpToken.transfer(owner, _amount), "Transfer failed");
    }

    // Función para obtener la lista de caridades registradas
    function getCharities() external view returns (Charity[] memory) {
        return charities;
    }
}

