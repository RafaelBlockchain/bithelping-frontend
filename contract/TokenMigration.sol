// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOldToken {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INewToken {
    function mint(address to, uint256 amount) external;
}

contract TokenMigration {
    address public owner;
    IOldToken public oldToken;
    INewToken public newToken;

    mapping(address => bool) public migrated;

    event TokensMigrated(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _oldToken, address _newToken) {
        require(_oldToken != address(0), "Invalid old token address");
        require(_newToken != address(0), "Invalid new token address");

        owner = msg.sender;
        oldToken = IOldToken(_oldToken);
        newToken = INewToken(_newToken);
    }

    /**
     * @dev Permite a los usuarios migrar sus tokens antiguos al nuevo token.
     */
    function migrateTokens() external {
        require(!migrated[msg.sender], "Tokens already migrated");

        uint256 userBalance = oldToken.balanceOf(msg.sender);
        require(userBalance > 0, "No tokens to migrate");

        // Transfiere los tokens antiguos al contrato
        require(oldToken.transferFrom(msg.sender, address(this), userBalance), "Token transfer failed");

        // Emite nuevos tokens equivalentes al saldo migrado
        newToken.mint(msg.sender, userBalance);

        // Marca al usuario como migrado
        migrated[msg.sender] = true;

        emit TokensMigrated(msg.sender, userBalance);
    }

    /**
     * @dev Permite al propietario retirar los tokens antiguos recolectados.
     * @param recipient Dirección a la que se enviarán los tokens antiguos.
     * @param amount Cantidad de tokens a retirar.
     */
    function withdrawOldTokens(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");

        require(oldToken.transferFrom(address(this), recipient, amount), "Withdrawal failed");
    }

    /**
     * @dev Consulta el saldo de tokens antiguos almacenados en este contrato.
     */
    function getOldTokenBalance() external view returns (uint256) {
        return oldToken.balanceOf(address(this));
    }
}

