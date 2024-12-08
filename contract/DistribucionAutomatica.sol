// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingDistribution {
    address public owner;
    IBITH public bithToken;
    uint256 public constant DISTRIBUTION_AMOUNT = 210 * 10**18; // 210 BITH (Asegúrate de ajustar las decimales)
    mapping(address => bool) public hasReceivedBith; // Mapeo para asegurarse de que cada dirección reciba solo una vez

    event TokensDistributed(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "No autorizado");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Dirección del contrato de BITH inválida");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Función para distribuir automáticamente los BITH a las direcciones registradas
    function distributeBith(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "Debe haber al menos una dirección");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(!hasReceivedBith[recipient], "Esta dirección ya ha recibido BITH");

            uint256 currentBalance = bithToken.balanceOf(address(this));
            require(currentBalance >= DISTRIBUTION_AMOUNT, "Saldo insuficiente en el contrato");

            // Transferir 210 BITH a cada usuario
            bithToken.transfer(recipient, DISTRIBUTION_AMOUNT);
            hasReceivedBith[recipient] = true; // Marcar como que ya ha recibido los tokens

            emit TokensDistributed(recipient, DISTRIBUTION_AMOUNT);
        }
    }

    // Función para reclamar BITH por parte de los usuarios
    function claimBith() external {
        require(!hasReceivedBith[msg.sender], "Ya has recibido tu asignación de BITH");
        
        uint256 currentBalance = bithToken.balanceOf(address(this));
        require(currentBalance >= DISTRIBUTION_AMOUNT, "Saldo insuficiente en el contrato");

        bithToken.transfer(msg.sender, DISTRIBUTION_AMOUNT);
        hasReceivedBith[msg.sender] = true; // Marcar como que ha recibido los tokens

        emit TokensClaimed(msg.sender, DISTRIBUTION_AMOUNT);
    }

    // Función para retirar tokens del contrato por el propietario
    function withdrawTokens(uint256 amount) external onlyOwner {
        uint256 currentBalance = bithToken.balanceOf(address(this));
        require(currentBalance >= amount, "Saldo insuficiente en el contrato");
        bithToken.transfer(owner, amount);
    }

    // Función para consultar el saldo de tokens en el contrato
    function contractBalance() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }
}

