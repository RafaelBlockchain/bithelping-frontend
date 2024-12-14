// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingSale {
    IBEP20 public bhelpToken; // Dirección del contrato del token BHELP
    address public owner;     // Dirección del propietario del contrato
    uint256 public price;     // Precio de 1 BHELP en BNB

    event TokensPurchased(address indexed buyer, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        bhelpToken = IBEP20(_tokenAddress);
        owner = msg.sender;

        // Establecer el precio inicial: 10,000,000 BHELP = 0.01 BNB
        price = 10**12; // 0.000000000001 BNB por token
    }

    // Comprar BHELP con BNB
    function buyTokens(uint256 tokenAmount) external payable {
        require(tokenAmount > 0, "Amount must be greater than 0");
        require(msg.value == tokenAmount * price, "Incorrect BNB value sent");
        require(bhelpToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in contract");

        // Transferir tokens al comprador
        bhelpToken.transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount);
    }

    // Retirar BNB recaudado
    function withdrawBNB() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Retirar los tokens restantes
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        bhelpToken.transfer(owner, amount);
    }

    // Cambiar el precio del token (si es necesario)
    function setPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        emit PriceUpdated(price, _price);
        price = _price;
    }

    // Consultar los tokens disponibles en el contrato
    function tokensAvailable() external view returns (uint256) {
        return bhelpToken.balanceOf(address(this));
    }

    // Fallback para recibir BNB
    receive() external payable {}
}


