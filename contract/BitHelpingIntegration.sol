// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBITH.sol";
import "./BitHelpingWallet.sol";
import "./BitHelpingSale.sol";
import "./BITHSwapIntegration.sol";
import "./BitHelpingDistribution.sol";
import "./BitHelpingGovernance.sol";
import "./BitHelpingMarketplace.sol";
import "./BitHelpingStaking.sol";
import "./FiatPayPalIntegration.sol";
import "./TariffManagement.sol";
import "./TransactionAudit.sol";

contract BitHelpingIntegration {
    IBITH public bithToken;
    BitHelpingWallet public walletContract;
    BitHelpingSale public saleContract;
    BITHSwapIntegration public swapContract;
    BitHelpingDistribution public distributionContract;
    BitHelpingGovernance public governanceContract;
    BitHelpingMarketplace public marketplaceContract;
    BitHelpingStaking public stakingContract;
    FiatPayPalIntegration public paypalContract;
    TariffManagement public tariffContract;
    TransactionAudit public auditContract;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(
        address _bithToken,
        address _walletContract,
        address _saleContract,
        address _swapContract,
        address _distributionContract,
        address _governanceContract,
        address _marketplaceContract,
        address _stakingContract,
        address _paypalContract,
        address _tariffContract,
        address _auditContract
    ) {
        require(_bithToken != address(0), "Invalid token address");
        require(_walletContract != address(0), "Invalid wallet contract address");
        require(_saleContract != address(0), "Invalid sale contract address");
        require(_swapContract != address(0), "Invalid swap contract address");
        require(_distributionContract != address(0), "Invalid distribution contract address");
        require(_governanceContract != address(0), "Invalid governance contract address");
        require(_marketplaceContract != address(0), "Invalid marketplace contract address");
        require(_stakingContract != address(0), "Invalid staking contract address");
        require(_paypalContract != address(0), "Invalid PayPal contract address");
        require(_tariffContract != address(0), "Invalid tariff contract address");
        require(_auditContract != address(0), "Invalid audit contract address");

        owner = msg.sender;
        bithToken = IBITH(_bithToken);
        walletContract = BitHelpingWallet(_walletContract);
        saleContract = BitHelpingSale(_saleContract);
        swapContract = BITHSwapIntegration(_swapContract);
        distributionContract = BitHelpingDistribution(_distributionContract);
        governanceContract = BitHelpingGovernance(_governanceContract);
        marketplaceContract = BitHelpingMarketplace(_marketplaceContract);
        stakingContract = BitHelpingStaking(_stakingContract);
        paypalContract = FiatPayPalIntegration(_paypalContract);
        tariffContract = TariffManagement(_tariffContract);
        auditContract = TransactionAudit(_auditContract);
    }

    // Método para consultar el balance de tokens en este contrato
    function getContractTokenBalance() external view returns (uint256) {
        return bithToken.balanceOf(address(this));
    }

    // Método para transferir tokens desde el contrato de integración
    function transferTokens(address recipient, uint256 amount) external onlyOwner {
        require(bithToken.transfer(recipient, amount), "Token transfer failed");
    }

    // Método para interactuar con contratos específicos
    function interactWithGovernance(bytes calldata data) external onlyOwner {
        (bool success,) = address(governanceContract).call(data);
        require(success, "Governance interaction failed");
    }

    function interactWithMarketplace(bytes calldata data) external onlyOwner {
        (bool success,) = address(marketplaceContract).call(data);
        require(success, "Marketplace interaction failed");
    }

    function interactWithStaking(bytes calldata data) external onlyOwner {
        (bool success,) = address(stakingContract).call(data);
        require(success, "Staking interaction failed");
    }

    // Método para reclamar tarifas acumuladas
    function claimFees(address recipient) external onlyOwner {
        require(tariffContract.claimFees(recipient), "Fee claim failed");
    }

    // Método para auditar una transacción
    function auditTransaction(bytes32 txHash) external view returns (bool) {
        return auditContract.isTransactionAudited(txHash);
    }
}

