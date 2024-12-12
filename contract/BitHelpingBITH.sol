// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBITH.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BitHelping is IBITH, Pausable, Ownable {
    // Mapeo para almacenar los saldos de los usuarios
    mapping(address => uint256) public balances;

    // Evento de emisión de tokens
    event Mint(address indexed to, uint256 amount);

    // Evento de quema de tokens
    event Burn(address indexed from, uint256 amount);

    // Función para transferir tokens
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    // Función para emitir nuevos tokens
    function mint(address to, uint256 amount) external override onlyOwner {
        require(to != address(0), "Invalid address");
        balances[to] += amount;
        emit Mint(to, amount);
    }

    // Función para quemar tokens
    function burnTokens(uint256 amount) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        emit Burn(msg.sender, amount);
        return true; // Retorna un valor booleano
    }

    // Función para pausar las operaciones del contrato
    function pause() external override onlyOwner {
        _pause();
    }

    // Función para reanudar las operaciones del contrato
    function unpause() external override onlyOwner {
        _unpause();
    }

    // Función para verificar si el contrato está pausado
    function isPaused() external view override returns (bool) {
        return paused();
    }

    // Función para consultar el balance de un usuario
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    // Implementación de migrateTokens
    function migrateTokens(address recipient, uint256 amount) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    // Constructor que inicializa el contrato Ownable con la dirección del propietario
    constructor(address initialOwner) Ownable(initialOwner) {
        // Aquí puedes agregar cualquier inicialización adicional si es necesario
    }
}


