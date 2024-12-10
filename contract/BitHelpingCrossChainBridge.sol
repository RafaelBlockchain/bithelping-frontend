// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface para el token BITH
interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function mint(address recipient, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

contract BitHelpingCrossChainBridge {
    address public owner;
    IBITH public bithToken;
    mapping(address => uint256) public pendingTransfers;

    // Eventos para registrar transferencias cross-chain
    event TransferInitiated(address indexed from, address indexed to, uint256 amount, uint256 chainId);
    event TransferCompleted(address indexed from, address indexed to, uint256 amount, uint256 chainId);

    // Modificadores para asegurar que solo el propietario del contrato pueda realizar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor
    constructor(address _bithToken) {
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Iniciar una transferencia a otra cadena
    function initiateCrossChainTransfer(address to, uint256 amount, uint256 targetChainId) external {
        require(bithToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > 0, "Amount must be greater than zero");

        // Quemar los tokens en la cadena actual
        bithToken.burn(msg.sender, amount);

        // Registrar la transferencia
        pendingTransfers[to] += amount;

        // Emitir evento de transferencia iniciada
        emit TransferInitiated(msg.sender, to, amount, targetChainId);
    }

    // Completar la transferencia en la cadena de destino (esto debe ser llamado por un validador o una entidad de confianza)
    function completeCrossChainTransfer(address from, address to, uint256 amount, uint256 sourceChainId) external onlyOwner {
        require(pendingTransfers[from] >= amount, "No pending transfer for this address");
        
        // Liberar los tokens en la cadena de destino (podría ser otro contrato de tokens en BSC, Polygon, etc.)
        bithToken.mint(to, amount);
        
        // Actualizar el saldo de las transferencias pendientes
        pendingTransfers[from] -= amount;

        // Emitir evento de transferencia completada
        emit TransferCompleted(from, to, amount, sourceChainId);
    }

    // Función de emergencia para que el propietario retire tokens BITH del contrato
    function withdrawBITH(uint256 amount) external onlyOwner {
        require(bithToken.transfer(owner, amount), "Transfer failed");
    }
}
