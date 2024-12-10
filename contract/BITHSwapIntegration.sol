// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BITHSwapIntegration is Ownable {
    IUniswapV2Router02 public uniswapRouter;
    address public bithToken;
    address public tariffManagementContract;

    event TokensSwapped(address indexed user, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(address indexed user, uint256 tokenAmount, uint256 ethAmount);
    event LiquidityRemoved(address indexed user, uint256 liquidity);
    event FeeCollected(address indexed user, uint256 feeAmount);

    constructor(address _router, address _bithToken, address _tariffContract) {
        require(_router != address(0), "Invalid router address");
        require(_bithToken != address(0), "Invalid BITH token address");
        require(_tariffContract != address(0), "Invalid tariff contract address");

        uniswapRouter = IUniswapV2Router02(_router);
        bithToken = _bithToken;
        tariffManagementContract = _tariffContract;
    }

    modifier validAddress(address addr) {
        require(addr != address(0), "Invalid address");
        _;
    }

    // Swapping BITH for another token
    function swapBITHForToken(address tokenOut, uint256 amountIn, uint256 amountOutMin) external {
        require(IERC20(bithToken).transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
        
        // Approve Uniswap router to spend BITH tokens
        IERC20(bithToken).approve(address(uniswapRouter), amountIn);

        address[] memory path = new address[](2);
        path[0] = bithToken;
        path[1] = tokenOut;

        uint256 fee = (amountIn * 3) / 1000; // 0.3% fee
        IERC20(bithToken).transfer(tariffManagementContract, fee);
        emit FeeCollected(msg.sender, fee);

        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn - fee,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        emit TokensSwapped(msg.sender, amountIn, amountOutMin);
    }

    // Add liquidity to Uniswap pool (BITH/ETH)
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external payable {
        require(msg.value == ethAmount, "Incorrect ETH amount");
        require(IERC20(bithToken).transferFrom(msg.sender, address(this), tokenAmount), "Transfer failed");

        IERC20(bithToken).approve(address(uniswapRouter), tokenAmount);

        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = uniswapRouter.addLiquidityETH{
            value: ethAmount
        }(
            bithToken,
            tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        emit LiquidityAdded(msg.sender, amountToken, amountETH);
    }

    // Remove liquidity from Uniswap pool (BITH/ETH)
    function removeLiquidity(address lpToken, uint256 liquidity) external {
        require(IERC20(lpToken).transferFrom(msg.sender, address(this), liquidity), "Transfer failed");

        IERC20(lpToken).approve(address(uniswapRouter), liquidity);

        (uint256 amountToken, uint256 amountETH) = uniswapRouter.removeLiquidityETH(
            bithToken,
            liquidity,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        emit LiquidityRemoved(msg.sender, liquidity);
    }

    // Update the tariff management contract
    function updateTariffManagementContract(address _tariffContract) external onlyOwner validAddress(_tariffContract) {
        tariffManagementContract = _tariffContract;
    }

    // Update the Uniswap router
    function updateUniswapRouter(address _router) external onlyOwner validAddress(_router) {
        uniswapRouter = IUniswapV2Router02(_router);
    }

    // Emergency withdrawal of tokens
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    // Emergency withdrawal of ETH
    function emergencyWithdrawETH(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}
