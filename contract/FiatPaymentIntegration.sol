// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract FiatPayPalIntegration {
    address public owner;
    IBITH public bithToken;
    mapping(address => uint256) public pendingClaims;

    event PaymentRegistered(address indexed buyer, uint256 tokenAmount);
    event TokensClaimed(address indexed buyer, uint256 tokenAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Registrar pagos confirmados desde el backend
    function registerPayment(address buyer, uint256 tokenAmount) external onlyOwner {
        require(buyer != address(0), "Invalid buyer address");
        require(tokenAmount > 0, "Invalid token amount");
        require(bithToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in contract");

        pendingClaims[buyer] += tokenAmount;

        emit PaymentRegistered(buyer, tokenAmount);
    }

    // Los usuarios pueden reclamar sus tokens después de un pago confirmado
    function claimTokens() external {
        uint256 tokenAmount = pendingClaims[msg.sender];
        require(tokenAmount > 0, "No tokens to claim");

        pendingClaims[msg.sender] = 0;
        bithToken.transfer(msg.sender, tokenAmount);

        emit TokensClaimed(msg.sender, tokenAmount);
    }
}

