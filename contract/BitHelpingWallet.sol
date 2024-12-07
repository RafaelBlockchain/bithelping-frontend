// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBitHelping {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function claimTokens() external;
    function newborns(address account) external view returns (
        uint256 allocation, 
        uint256 unlockTime, 
        bool registered
    );
}

contract BitHelpingWallet {
    address public immutable bitHelping; // Dirección del contrato BitHelping
    address public owner; // Propietario de la cartera (representa al recién nacido o su tutor)
    address public newborn; // Dirección del recién nacido
    uint256 public unlockTime; // Fecha en la que los tokens estarán desbloqueados

    // Eventos
    event TokensWithdrawn(address indexed by, uint256 amount);
    event TokensTransferred(address indexed to, uint256 amount);
    event WalletOwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyAfterUnlock() {
        require(block.timestamp >= unlockTime, "Tokens are still locked");
        _;
    }

    constructor(address _bitHelping, address _newborn) {
        require(_bitHelping != address(0), "Invalid BitHelping address");
        require(_newborn != address(0), "Invalid newborn address");

        bitHelping = _bitHelping;
        newborn = _newborn;
        owner = msg.sender;

        // Obtener el tiempo de desbloqueo desde BitHelping
        (, uint256 _unlockTime, bool registered) = IBitHelping(bitHelping).newborns(_newborn);
        require(registered, "Newborn not registered in BitHelping");
        unlockTime = _unlockTime;
    }

    // Consultar saldo actual en BitHelping
    function balance() public view returns (uint256) {
        return IBitHelping(bitHelping).balanceOf(address(this));
    }

    // Reclamar tokens desde BitHelping al wallet
    function claimTokens() public onlyOwner onlyAfterUnlock {
        IBitHelping(bitHelping).claimTokens();
    }

    // Transferir tokens desde el wallet a otra dirección
    function transfer(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(balance() >= amount, "Insufficient balance");

        // Transferencia de tokens a través del contrato BitHelping
        bool success = IBitHelping(bitHelping).transfer(to, amount);
        require(success, "Token transfer failed");

        emit TokensTransferred(to, amount);
    }

    // Cambiar el propietario de la cartera (e.g., en caso de cambio de tutor legal)
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        emit WalletOwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Fallback para rechazar envíos de ETH al contrato
    receive() external payable {
        revert("ETH not accepted");
    }
}

