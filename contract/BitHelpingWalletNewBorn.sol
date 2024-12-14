// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function claimTokens() external;
    function newborns(address account) external view returns (
        uint256 allocation, 
        uint256 unlockTime, 
        bool registered
    );
}

contract BitHelpingWalletNewBornBEP20 {
    address public immutable bitHelping; // Dirección del contrato BEP-20 de BHELP
    address public owner; // Propietario de la billetera (guardian legal)
    address public newborn; // Dirección del recién nacido registrado
    uint256 public unlockTime; // Fecha de desbloqueo de los tokens

    // Mapping para almacenar balances de BHELP
    mapping(address => uint256) private bhelpBalances;

    // Eventos para seguimiento
    event TokensWithdrawn(address indexed by, uint256 amount);
    event TokensTransferred(address indexed to, uint256 amount);
    event WalletOwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event NewbornRegistered(address indexed newborn, uint256 unlockTime);
    event BHELPDeposited(address indexed from, uint256 amount);
    event BHELPWithdrawn(address indexed to, uint256 amount);

    // Modificadores para restringir acciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyAfterUnlock() {
        require(newborn != address(0), "Newborn not registered");
        require(block.timestamp >= unlockTime, "Tokens are still locked");
        _;
    }

    modifier newbornRegistered() {
        require(newborn != address(0), "Newborn not registered");
        _;
    }

    constructor(address _bitHelping) {
        require(_bitHelping != address(0), "Invalid BitHelping address");
        bitHelping = _bitHelping;
        owner = msg.sender;
    }

    // Registrar dinámicamente un recién nacido
    function registerNewborn(address _newborn) external onlyOwner {
        require(_newborn != address(0), "Invalid newborn address");
        require(newborn == address(0), "Newborn already registered");

        // Obtener tiempo de desbloqueo del contrato principal
        (, uint256 _unlockTime, bool registered) = IBEP20(bitHelping).newborns(_newborn);
        require(registered, "Newborn not registered in BitHelping");

        newborn = _newborn;
        unlockTime = _unlockTime;

        emit NewbornRegistered(_newborn, _unlockTime);
    }

    // Consultar el balance actual de BHELP en la billetera
    function bhelpBalance() public view newbornRegistered returns (uint256) {
        return bhelpBalances[newborn];
    }

    // Depositar BHELP en la billetera
    function depositBHELP(uint256 amount) external newbornRegistered {
        require(amount > 0, "Deposit amount must be greater than zero");

        // Simular la transferencia de BHELP al contrato
        bool success = IBEP20(bitHelping).transfer(address(this), amount);
        require(success, "BHELP transfer failed");

        bhelpBalances[newborn] += amount;
        emit BHELPDeposited(msg.sender, amount);
    }

    // Retirar BHELP de la billetera (después del tiempo de desbloqueo)
    function withdrawBHELP(uint256 amount) external onlyOwner onlyAfterUnlock {
        require(bhelpBalances[newborn] >= amount, "Insufficient BHELP balance");

        // Simular la transferencia de BHELP al propietario
        bool success = IBEP20(bitHelping).transfer(owner, amount);
        require(success, "BHELP transfer failed");

        bhelpBalances[newborn] -= amount;
        emit BHELPWithdrawn(owner, amount);
    }

    // Transferir BHELP a otra dirección
    function transferBHELP(address to, uint256 amount) external onlyOwner newbornRegistered {
        require(to != address(0), "Invalid recipient address");
        require(bhelpBalances[newborn] >= amount, "Insufficient BHELP balance");

        // Simular la transferencia de BHELP al destinatario
        bool success = IBEP20(bitHelping).transfer(to, amount);
        require(success, "BHELP transfer failed");

        bhelpBalances[newborn] -= amount;
        emit TokensTransferred(to, amount);
    }

    // Cambiar el propietario de la billetera
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");

        emit WalletOwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Función específica de BEP-20 para obtener el propietario
    function getOwner() external view returns (address) {
        return owner;
    }
}

