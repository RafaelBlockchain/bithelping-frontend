// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./BitHelping.sol"; // Importar el contrato de BitHelping (BITH)

contract TokenSale {
    BitHelpingToken public bithToken; // Dirección del contrato de BitHelping Token
    address public owner; // Dirección del propietario del contrato de venta
    uint256 public rate = 100000000; // Tasa de cambio: 1 BNB = 100,000,000 BITH
    address public feeAddress = 0x37ecD018805ac8b0D34a535EC5C62A5C136F2265; // Dirección del fee

    // Eventos
    event TokensPurchased(address buyer, uint256 amountSpent, uint256 tokensReceived, uint256 feePaid);

    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _bithTokenAddress) {
        bithToken = BitHelpingToken(_bithTokenAddress);
        owner = msg.sender;
    }

    // Función de compra de tokens
    function buyTokens() public payable {
        uint256 amountToSpend = msg.value; // La cantidad de BNB enviada por el comprador
        uint256 tokensToReceive = amountToSpend * rate; // Calcula los BITH que el comprador recibe

        // Calcular el fee (0.8%) y la cantidad de tokens que el comprador recibirá
        uint256 fee = (tokensToReceive * 8) / 1000; // Fee es el 0.8% de los tokens a recibir
        uint256 tokensAfterFee = tokensToReceive - fee; // Tokens que el comprador recibe después de descontar el fee

        // Verificar si el contrato tiene suficientes BITH para transferir
        require(bithToken.balanceOf(address(this)) >= tokensToReceive, "Not enough tokens available");

        // Transferir el fee a la dirección de fee
        require(bithToken.transfer(feeAddress, fee), "Fee transfer failed");

        // Transferir los tokens al comprador
        require(bithToken.transfer(msg.sender, tokensAfterFee), "Token transfer failed");

        // Emitir un evento de compra
        emit TokensPurchased(msg.sender, amountToSpend, tokensAfterFee, fee);
    }

    // Función para que el propietario retire los fondos acumulados en BNB
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance); // Retirar BNB a la dirección del propietario
    }

    // Función para que el propietario retire los tokens sobrantes
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(bithToken.transfer(owner, amount), "Token transfer failed");
    }
}

