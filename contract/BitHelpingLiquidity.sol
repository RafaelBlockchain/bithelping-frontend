// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

// Interfaces para interactuar con PancakeSwap y el token BEP-20
interface IPancakeV2Router {
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

interface IPancakeV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

contract BitHelpingLiquidity {
    address public owner;
    address public bhelpToken; // Dirección del token BHELP
    address public pancakeRouter; // Dirección del router de PancakeSwap
    address public pancakeFactory; // Dirección de la fábrica de PancakeSwap
    address public wbnb; // Dirección de Wrapped BNB (WBNB)

    event LiquidityAdded(uint amountToken, uint amountETH, uint liquidity);
    event LiquidityRemoved(uint amountToken, uint amountETH);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _bhelpToken, address _pancakeRouter, address _pancakeFactory, address _wbnb) {
        require(_bhelpToken != address(0), "Invalid token address");
        require(_pancakeRouter != address(0), "Invalid router address");
        require(_pancakeFactory != address(0), "Invalid factory address");
        require(_wbnb != address(0), "Invalid WBNB address");

        owner = msg.sender;
        bhelpToken = _bhelpToken;
        pancakeRouter = _pancakeRouter;
        pancakeFactory = _pancakeFactory;
        wbnb = _wbnb;
    }

    // Función para agregar liquidez
    function addLiquidity(uint amountToken, uint amountTokenMin, uint amountETHMin, uint deadline) external payable onlyOwner {
        IERC20(bhelpToken).transferFrom(msg.sender, address(this), amountToken);  // Transferir tokens al contrato
        IERC20(bhelpToken).approve(pancakeRouter, amountToken);  // Aprobar el router para gastar los tokens

        (uint amountTokenActual, uint amountETHActual, uint liquidity) = IPancakeV2Router(pancakeRouter).addLiquidityETH{
            value: msg.value
        }(
            bhelpToken,
            amountToken,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        emit LiquidityAdded(amountTokenActual, amountETHActual, liquidity);
    }

    // Función para eliminar liquidez
    function removeLiquidity(uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline) external onlyOwner {
        IERC20(pairAddress()).approve(pancakeRouter, liquidity);  // Aprobar el par para eliminar liquidez

        (uint amountToken, uint amountETH) = IPancakeV2Router(pancakeRouter).removeLiquidityETH(
            bhelpToken,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        // Transferir los tokens y BNB al propietario
        IERC20(bhelpToken).transfer(owner, amountToken);  // Transferir tokens al propietario
        payable(owner).transfer(amountETH);  // Transferir BNB al propietario

        emit LiquidityRemoved(amountToken, amountETH);
    }

    // Obtener la dirección del par en PancakeSwap
    function pairAddress() public view returns (address pair) {
        return IPancakeV2Factory(pancakeFactory).getPair(bhelpToken, wbnb);
    }

    // Función de emergencia para retirar fondos
    function emergencyWithdraw(uint amountToken, uint amountETH) external onlyOwner {
        if (amountToken > 0) {
            IERC20(bhelpToken).transfer(owner, amountToken);  // Retirar tokens
        }
        if (amountETH > 0) {
            payable(owner).transfer(amountETH);  // Retirar BNB
        }
    }

    // Recibir BNB
    receive() external payable {}
}

