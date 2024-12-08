// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBITH.sol"; // El token BITH
import "./BitHelpingWallet.sol"; // El contrato del monedero
import "./BitHelpingSale.sol"; // El contrato de venta de tokens
import "./BITHSwapIntegration.sol"; // El contrato de intercambio BITH
import "./BitHelpingDistribution.sol"; // El contrato de distribución automática
import "./BitHelpingGobernance.sol"; // El contrato de gobernanza (DAO)
import "./BitHelpingMarketplace.sol"; // El contrato de Marketplace
import "./BitHelpingStaking.sol"; // El contrato de Staking
import "./FiatPayPalIntegration.sol"; // El contrato de integración con PayPal
import "./TariffManagement.sol"; // El contrato de gestión de tarifas
import "./TransactionAudit.sol"; // El contrato de auditoría de transacciones

contract BitHelpingIntegration {
    
    // Declaración de los contratos integrados
    IBITH public bithToken;
    BitHelpingWallet public wallet;
    BitHelpingSale public sale;
    BITHSwapIntegration public swapIntegration;
    BitHelpingDistribution public distribution;
    BitHelpingGobernance public governance;
    BitHelpingMarketplace public marketplace;
    BitHelpingStaking public staking;
    FiatPayPalIntegration public fiatPayPal;
    TariffManagement public tariffs;
    TransactionAudit public audit;

    address public owner;

    event TokenSale(address indexed buyer, uint256 amount);
    event TokensStaked(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);
    event MarketplaceTransaction(address indexed seller, address indexed buyer, uint256 tokenAmount);
    event PaymentRegistered(address indexed buyer, uint256 tokenAmount);
    event FeesUpdated(uint256 newTransactionFee, uint256 newStakingFee, uint256 newWithdrawalFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(
        address _bithToken,
        address _wallet,
        address _sale,
        address _swapIntegration,
        address _distribution,
        address _governance,
        address _marketplace,
        address _staking,
        address _fiatPayPal,
        address _tariffs,
        address _audit
    ) {
        owner = msg.sender;

        bithToken = IBITH(_bithToken);
        wallet = BitHelpingWallet(_wallet);
        sale = BitHelpingSale(_sale);
        swapIntegration = BITHSwapIntegration(_swapIntegration);
        distribution = BitHelpingDistribution(_distribution);
        governance = BitHelpingGobernance(_governance);
        marketplace = BitHelpingMarketplace(_marketplace);
        staking = BitHelpingStaking(_staking);
        fiatPayPal = FiatPayPalIntegration(_fiatPayPal);
        tariffs = TariffManagement(_tariffs);
        audit = TransactionAudit(_audit);
    }

    // Función para comprar tokens a través de la venta
    function buyTokens(uint256 tokenAmount) external payable {
        sale.buyTokens{value: msg.value}(tokenAmount);
        emit TokenSale(msg.sender, tokenAmount);
    }

    // Función para realizar staking de BITH
    function stakeTokens(uint256 tokenAmount) external {
        staking.stake(tokenAmount);
        emit TokensStaked(msg.sender, tokenAmount);
    }

    // Función para reclamar tokens de staking
    function claimStakedTokens() external {
        staking.claimTokens();
        emit TokensClaimed(msg.sender, staking.balanceOf(msg.sender));
    }

    // Función para realizar transacciones en el marketplace
    function marketplaceTransaction(address buyer, uint256 tokenAmount) external {
        marketplace.buyItem(buyer, tokenAmount);
        emit MarketplaceTransaction(msg.sender, buyer, tokenAmount);
    }

    // Función para distribuir tokens automáticamente a los recién nacidos (ejemplo de distribución)
    function distributeTokens(address recipient, uint256 tokenAmount) external onlyOwner {
        distribution.distribute(recipient, tokenAmount);
    }

    // Función para registrar pagos confirmados desde el backend (ejemplo de integración con PayPal)
    function registerPayment(address buyer, uint256 tokenAmount) external onlyOwner {
        fiatPayPal.registerPayment(buyer, tokenAmount);
        emit PaymentRegistered(buyer, tokenAmount);
    }

    // Función para actualizar tarifas
    function updateFees(uint256 transactionFee, uint256 stakingFee, uint256 withdrawalFee) external onlyOwner {
        tariffs.updateTransactionFee(transactionFee);
        tariffs.updateStakingFee(stakingFee);
        tariffs.updateWithdrawalFee(withdrawalFee);
        emit FeesUpdated(transactionFee, stakingFee, withdrawalFee);
    }

    // Función para consultar las tarifas
    function getFees() external view returns (uint256, uint256, uint256) {
        return tariffs.getFees();
    }

    // Función para auditar transacciones
    function auditTransaction(address buyer, uint256 tokenAmount) external onlyOwner {
        audit.registerTransaction(buyer, tokenAmount);
    }

    // Función para gestionar la gobernanza (DAO)
    function voteOnProposal(uint256 proposalId, bool approve) external {
        governance.vote(proposalId, approve);
    }

    // Función para realizar un intercambio de tokens (Swap)
    function swapTokens(uint256 amount, address toToken) external {
        swapIntegration.swap(amount, toToken);
    }
}

