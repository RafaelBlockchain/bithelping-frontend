// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Chainlink Interfaces
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// Interface for the BITH Token
interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingOracleIntegration is VRFConsumerBase {
    // Chainlink contract address for getting data (e.g., ETH price)
    AggregatorV3Interface internal priceFeed;

    address public owner;
    IBITH public bithToken;
    uint256 public lastPrice;

    // Chainlink VRF parameters
    bytes32 internal keyHash;
    uint256 internal fee;

    // Event to log price updates
    event PriceUpdated(uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    constructor(address _bithToken, address _priceFeed, address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee) 
        VRFConsumerBase(_vrfCoordinator, _linkToken) 
    {
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
        keyHash = _keyHash;
        fee = _fee;
    }

    // Function to get the price of an asset (e.g., ETH/USD) from the oracle
    function getLatestPrice() public view returns (int) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    // Function to get the price of an asset as uint256 (without decimals)
    function getLatestPriceUint() public view returns (uint256) {
        int price = getLatestPrice();
        require(price > 0, "Price data is invalid");
        return uint256(price);
    }

    // Function to request a new random price (using Chainlink VRF for randomness or more data)
    function requestNewRandomPrice() public onlyOwner {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK to pay for request");
        requestRandomness(keyHash, fee);
    }

    // Callback function to handle the VRF response
    function fulfillRandomness(bytes32 /* requestId */, uint256 randomness) internal override {
        uint256 newPrice = randomness % 1000; // Example adjustment for price
        lastPrice = newPrice;
        emit PriceUpdated(newPrice);
    }

    // Function to withdraw LINK tokens if necessary
    function withdrawLink(uint256 amount) public onlyOwner {
        require(LINK.transfer(owner, amount), "Unable to transfer LINK");
    }

    // Function to withdraw accumulated BITH tokens (only owner)
    function withdrawBITH(uint256 amount) public onlyOwner {
        require(bithToken.transfer(owner, amount), "Transfer failed");
    }

    // Emergency function to manually change the price (only owner)
    function setManualPrice(uint256 price) external onlyOwner {
        lastPrice = price;
        emit PriceUpdated(price);
    }
}

