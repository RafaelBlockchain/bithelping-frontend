// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;

// Interfaz para interactuar con el token BEP-20 BHELP
interface IBHELP {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
}

contract BitHelpingBurn {
    address public owner;
    IBHELP public bhelpToken;

    event TokensBurned(address indexed burner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bhelpToken) {
        require(_bhelpToken != address(0), "Invalid token address");
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    /**
     * @dev Permite al propietario quemar tokens desde el contrato.
     * @param amount La cantidad de tokens a quemar.
     */
    function ownerBurn(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bhelpToken.balanceOf(address(this)) >= amount, "Insufficient tokens in contract");

        bhelpToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Permite a los usuarios quemar sus propios tokens.
     * @param amount La cantidad de tokens a quemar.
     */
    function userBurn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(bhelpToken.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Transferir tokens al contrato para quemarlos
        require(bhelpToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Quemar los tokens desde el contrato
        bhelpToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Permite al propietario transferir tokens al contrato para ser quemados manualmente.
     * @param amount La cantidad de tokens a transferir al contrato para ser quemados.
     */
    function fundBurnPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bhelpToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    /**
     * @dev Devuelve el saldo actual de tokens almacenados en el contrato para ser quemados.
     * @return El saldo de tokens en el contrato.
     */
    function getBurnPoolBalance() external view returns (uint256) {
        return bhelpToken.balanceOf(address(this));
    }
}

