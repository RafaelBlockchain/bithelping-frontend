// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBitHelping {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IBitHelpingSale {
    function buyTokens(uint256 tokenAmount) external payable;
    function tokensAvailable() external view returns (uint256);
    function setPrice(uint256 _price) external;
    function withdrawETH() external;
}

interface IBitHelpingWallet {
    function transfer(address to, uint256 amount) external;
    function balance() external view returns (uint256);
    function transferOwnership(address newOwner) external;
}

contract BitHelpingIntegration {
    address public owner;
    IBitHelping public bithToken;
    IBitHelpingSale public bithSale;
    IBitHelpingWallet public bithWallet;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event WalletInteraction(address indexed wallet, address indexed to, uint256 amount);
    event PriceUpdated(uint256 newPrice);
    event OwnershipTransferred(address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken, address _bithSale, address _bithWallet) {
        require(_bithToken != address(0), "Invalid token address");
        require(_bithSale != address(0), "Invalid sale address");
        require(_bithWallet != address(0), "Invalid wallet address");

        owner = msg.sender;
        bithToken = IBitHelping(_bithToken);
        bithSale = IBitHelpingSale(_bithSale);
        bithWallet = IBitHelpingWallet(_bithWallet);
    }

    // --- Funciones de Compra de Tokens ---
    function buyTokens(uint256 tokenAmount) external payable {
        bithSale.buyTokens{value: msg.value}(tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function tokensAvailable() external view returns (uint256) {
        return bithSale.tokensAvailable();
    }

    function updateTokenPrice(uint256 newPrice) external onlyOwner {
        bithSale.setPrice(newPrice);
        emit PriceUpdated(newPrice);
    }

    // --- Funciones de Gestión de Wallet ---
    function transferFromWallet(address to, uint256 amount) external onlyOwner {
        bithWallet.transfer(to, amount);
        emit WalletInteraction(address(bithWallet), to, amount);
    }

    function walletBalance() external view returns (uint256) {
        return bithWallet.balance();
    }

    function transferWalletOwnership(address newOwner) external onlyOwner {
        bithWallet.transferOwnership(newOwner);
        emit OwnershipTransferred(newOwner);
    }

    // --- Funciones de Retiro ---
    function withdrawETH() external onlyOwner {
        bithSale.withdrawETH();
        payable(owner).transfer(address(this).balance);
    }

    // --- Funciones de Transferencia de Tokens ---
    function transferTokens(address to, uint256 amount) external onlyOwner {
        require(bithToken.transfer(to, amount), "Token transfer failed");
    }

    function tokenBalance() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }

    // --- Fallback para recibir ETH ---
    receive() external payable {}
}

