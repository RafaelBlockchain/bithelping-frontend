// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingSale {
    IERC20 public bithToken; // Dirección del contrato del token BITH
    address public owner;    // Dirección del dueño del contrato
    uint256 public price;    // Precio de 1 BITH en Wei (ETH)

    event TokensPurchased(address indexed buyer, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        bithToken = IERC20(_tokenAddress);
        owner = msg.sender;

        // Establecer el precio inicial: 10,000,000 BITH = 0.01 ETH
        price = 10**12; // 0.000000000001 ETH por token
    }

    // Comprar BITH con ETH
    function buyTokens(uint256 tokenAmount) external payable {
        require(tokenAmount > 0, "Amount must be greater than 0");
        require(msg.value == tokenAmount * price, "Incorrect ETH value sent");
        require(bithToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in contract");

        // Transferir tokens al comprador
        bithToken.transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount);
    }

    // Retirar ETH recaudado
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Retirar tokens restantes
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        bithToken.transfer(owner, amount);
    }

    // Cambiar el precio por token (en caso necesario)
    function setPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        emit PriceUpdated(price, _price);
        price = _price;
    }

    // Consultar tokens disponibles en el contrato
    function tokensAvailable() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }

    // Fallback para recibir ETH
    receive() external payable {}
}

