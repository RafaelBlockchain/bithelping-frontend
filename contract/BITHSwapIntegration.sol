// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";

contract BITHSwapIntegration {
    address public owner;
    IUniswapV2Router02 public uniswapRouter; // Router de Uniswap o PancakeSwap
    IERC20 public bithToken; // Token BITH

    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);
    event TokensSwapped(address indexed user, uint256 tokenAmount, uint256 ethAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _router, address _bithToken) {
        require(_router != address(0), "Invalid router address");
        require(_bithToken != address(0), "Invalid token address");

        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(_router);
        bithToken = IERC20(_bithToken);
    }

    /**
     * @dev Agregar liquidez al pool (BITH/ETH)
     */
    function addLiquidity(uint256 tokenAmount) external payable onlyOwner {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(msg.value > 0, "ETH amount must be greater than 0");

        // Aprobar tokens para el router
        bithToken.approve(address(uniswapRouter), tokenAmount);

        // Agregar liquidez
        uniswapRouter.addLiquidityETH{value: msg.value}(
            address(bithToken), // Dirección del token
            tokenAmount,        // Cantidad de tokens a agregar
            0,                  // Mínimos permitidos (puedes ajustar estos valores)
            0,                  // Mínimos permitidos
            owner,              // Dirección que recibirá los tokens LP
            block.timestamp     // Fecha límite
        );

        emit LiquidityAdded(tokenAmount, msg.value);
    }

    /**
     * @dev Intercambiar ETH por BITH
     */
    function swapETHForTokens(uint256 minTokens) external payable {
        require(msg.value > 0, "ETH amount must be greater than 0");

        // Ruta del intercambio: ETH -> BITH
        address;
        path[0] = uniswapRouter.WETH(); // Dirección de WETH
        path[1] = address(bithToken);   // Dirección del token BITH

        // Ejecutar intercambio
        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            minTokens,     // Cantidad mínima de tokens a recibir
            path,          // Ruta del intercambio
            msg.sender,    // Dirección que recibe los tokens
            block.timestamp // Fecha límite
        );
    }

    /**
     * @dev Intercambiar BITH por ETH
     */
    function swapTokensForETH(uint256 tokenAmount, uint256 minETH) external {
        require(tokenAmount > 0, "Token amount must be greater than 0");

        // Aprobar tokens para el router
        bithToken.approve(address(uniswapRouter), tokenAmount);

        // Ruta del intercambio: BITH -> ETH
        address;
        path[0] = address(bithToken);  // Dirección del token BITH
        path[1] = uniswapRouter.WETH(); // Dirección de WETH

        // Ejecutar intercambio
        uniswapRouter.swapExactTokensForETH(
            tokenAmount,   // Cantidad de tokens a intercambiar
            minETH,        // Cantidad mínima de ETH a recibir
            path,          // Ruta del intercambio
            msg.sender,    // Dirección que recibe el ETH
            block.timestamp // Fecha límite
        );

        emit TokensSwapped(msg.sender, tokenAmount, minETH);
    }

    /**
     * @dev Retirar tokens o ETH del contrato
     */
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner, amount);
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback para recibir ETH
    receive() external payable {}
}

