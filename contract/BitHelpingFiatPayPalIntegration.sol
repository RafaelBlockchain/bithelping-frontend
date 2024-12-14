// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the BEP20 Token (BHELP Token)
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingFiatPaypalIntegration {

    // Token utilizado para realizar las donaciones o transacciones
    IBHELP public bhelpToken;

    // Dirección del propietario del contrato
    address public owner;

    // Dirección de PayPal para recibir pagos (esto es solo un ejemplo, PayPal no se puede integrar directamente en Solidity)
    address public paypalAddress;

    // Mapeo para almacenar pagos realizados
    mapping(address => uint256) public paymentsReceived;

    // Eventos
    event PaymentReceived(address indexed payer, uint256 amount, string paymentMethod);
    event Withdrawal(address indexed owner, uint256 amount);

    // Modificador que asegura que solo el propietario puede ejecutar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Only the owner can perform this action");
        _;
    }

    // Constructor para establecer el token BHELP y la dirección del propietario
    constructor(address _bhelpToken, address _paypalAddress) {
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
        paypalAddress = _paypalAddress;
    }

    // Función para recibir pagos en fiat (en este caso, a través de PayPal)
    // Esta función no interactúa directamente con PayPal. Necesitarás un servidor fuera de la cadena para verificar el pago con PayPal.
    function receivePayment(uint256 _amount, string memory _paymentMethod) external payable {
        require(_amount > 0, "Payment amount must be greater than zero");
        require(msg.value >= _amount, "Insufficient amount sent via PayPal");

        // Registrar el pago realizado por la dirección que envió el fiat
        paymentsReceived[msg.sender] += _amount;

        // Emitir el evento de pago
        emit PaymentReceived(msg.sender, _amount, _paymentMethod);
    }

    // Función para convertir el pago recibido en fiat (en este caso, se simula como un pago exitoso)
    // En este punto, se podrían transferir tokens BEP20 al donante si fuera necesario
    function convertPaymentToTokens(address _recipient, uint256 _amount) external onlyOwner {
        // Verificar que el propietario tenga suficiente saldo de BHELP para transferir
        uint256 balance = bhelpToken.balanceOf(owner);
        require(balance >= _amount, "Insufficient BHELP tokens in contract");

        // Transferir los tokens BHELP al destinatario
        bhelpToken.transfer(_recipient, _amount);
    }

    // Función para realizar un retiro de tokens BHELP (solo el propietario puede hacerlo)
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 balance = bhelpToken.balanceOf(address(this));
        require(balance >= _amount, "Insufficient balance to withdraw");

        // Realizar el retiro de tokens BHELP
        require(bhelpToken.transfer(owner, _amount), "Transfer failed");

        // Emitir el evento de retiro
        emit Withdrawal(owner, _amount);
    }

    // Función para obtener el saldo de pagos de una dirección
    function getPaymentBalance(address _payer) external view returns (uint256) {
        return paymentsReceived[_payer];
    }
}

