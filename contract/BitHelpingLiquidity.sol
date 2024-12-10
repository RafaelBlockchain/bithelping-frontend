// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces para interactuar con Uniswap V2
interface IUniswapV2Router {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
}

interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

contract BitHelpingLiquidity {
    address public owner;
    address public bithToken; // Dirección del token BITH
    address public uniswapRouter; // Dirección del router de Uniswap

    event LiquidityAdded(uint amountToken, uint amountETH, uint liquidity);
    event LiquidityRemoved(uint amountToken, uint amountETH);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bithToken, address _uniswapRouter) {
        require(_bithToken != address(0), "Invalid token address");
        require(_uniswapRouter != address(0), "Invalid router address");
        owner = msg.sender;
        bithToken = _bithToken;
        uniswapRouter = _uniswapRouter;
    }

    // Función para añadir liquidez
    function addLiquidity(uint amountToken, uint amountTokenMin, uint amountETHMin, uint deadline) external payable onlyOwner {
        IERC20(bithToken).transferFrom(msg.sender, address(this), amountToken);
        IERC20(bithToken).approve(uniswapRouter, amountToken);

        (uint amountTokenActual, uint amountETHActual, uint liquidity) = IUniswapV2Router(uniswapRouter).addLiquidityETH{
            value: msg.value
        }(
            bithToken,
            amountToken,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        emit LiquidityAdded(amountTokenActual, amountETHActual, liquidity);
    }

    // Función para retirar liquidez
    function removeLiquidity(uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline) external onlyOwner {
        IERC20 pair = IERC20(getPairAddress());
        pair.approve(uniswapRouter, liquidity);

        (uint amountToken, uint amountETH) = IUniswapV2Router(uniswapRouter).removeLiquidityETH(
            bithToken,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        // Transferir tokens y ETH al propietario
        IERC20(bithToken).transfer(owner, amountToken);
        payable(owner).transfer(amountETH);

        emit LiquidityRemoved(amountToken, amountETH);
    }

    // Obtener la dirección del par de liquidez en Uniswap
    function getPairAddress() public view returns (address pair) {
        // Código para determinar el par correspondiente al token BITH
        // En Uniswap V2 se necesita calcular manualmente o usar un contrato factory.
        return address(0); // Sustituir con la lógica de obtener la dirección del par
    }

    // Permitir al propietario retirar fondos en caso de emergencia
    function emergencyWithdraw(uint amountToken, uint amountETH) external onlyOwner {
        if (amountToken > 0) {
            IERC20(bithToken).transfer(owner, amountToken);
        }
        if (amountETH > 0) {
            payable(owner).transfer(amountETH);
        }
    }

    // Recibir ETH
    receive() external payable {}
}

