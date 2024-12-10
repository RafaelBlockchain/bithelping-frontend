// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
}

contract BitHelpingBurn {
    address public owner;
    IBITH public bithToken;

    event TokensBurned(address indexed burner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    /**
     * @dev Permite al propietario quemar tokens desde el contrato.
     * @param amount La cantidad de tokens a quemar.
     */
    function ownerBurn(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.balanceOf(address(this)) >= amount, "Insufficient tokens in contract");

        bithToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Permite a los usuarios quemar sus propios tokens.
     * @param amount La cantidad de tokens a quemar.
     */
    function userBurn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Transferir tokens al contrato para quemarlos
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Quemar los tokens desde el contrato
        bithToken.burn(amount);

        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Permite transferir tokens al contrato para quemarlos manualmente.
     * Solo el propietario puede ejecutar esta función.
     * @param amount La cantidad de tokens que se transferirán al contrato para ser quemados.
     */
    function fundBurnPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(bithToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    /**
     * @dev Consulta el saldo actual de tokens almacenados en el contrato para quemar.
     * @return El saldo de tokens.
     */
    function getBurnPoolBalance() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }
}

