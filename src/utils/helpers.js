import Web3 from 'web3';

// Configuración de redes admitidas en el proyecto
const supportedNetworks = {
  1: { name: 'Ethereum Mainnet', explorer: 'https://etherscan.io' },
  56: { name: 'Binance Smart Chain', explorer: 'https://bscscan.com' },
  137: { name: 'Polygon Mainnet', explorer: 'https://polygonscan.com' },
  5: { name: 'Goerli Testnet', explorer: 'https://goerli.etherscan.io' },
  97: { name: 'BSC Testnet', explorer: 'https://testnet.bscscan.com' },
  80001: { name: 'Mumbai Testnet', explorer: 'https://mumbai.polygonscan.com' },
};

/**
 * Convierte una cantidad de Wei a ETH (o su equivalente en otras cadenas EVM).
 * @param {string | number} wei - Cantidad en Wei.
 * @returns {string} - Cantidad en ETH.
 */
export function weiToEth(wei) {
  return (parseFloat(wei) / 1e18).toFixed(6);
}

/**
 * Convierte una cantidad de ETH a Wei.
 * @param {string | number} eth - Cantidad en ETH.
 * @returns {string} - Cantidad en Wei.
 */
export function ethToWei(eth) {
  return (parseFloat(eth) * 1e18).toString();
}

/**
 * Valida si una dirección es válida en Ethereum u otras redes EVM.
 * @param {string} address - Dirección de la billetera.
 * @returns {boolean} - True si es válida, false de lo contrario.
 */
export function isValidAddress(address) {
  return Web3.utils.isAddress(address);
}

/**
 * Obtiene el nombre y detalles de una red soportada basada en su Chain ID.
 * @param {number} chainId - ID de la red.
 * @returns {object} - Nombre y URL del explorador de la red.
 */
export function getNetworkDetails(chainId) {
  return supportedNetworks[chainId] || { name: 'Unknown Network', explorer: '' };
}

/**
 * Genera un link al explorador de blockchain para una transacción.
 * @param {number} chainId - Chain ID de la red.
 * @param {string} txHash - Hash de la transacción.
 * @returns {string} - URL de la transacción en el explorador.
 */
export function generateExplorerLink(chainId, txHash) {
  const network = getNetworkDetails(chainId);
  if (network.explorer) {
    return `${network.explorer}/tx/${txHash}`;
  }
  return 'Explorador no disponible';
}

/**
 * Valida si un pago de PayPal se completó con éxito.
 * @param {object} payment - Detalles del pago desde el backend.
 * @returns {boolean} - True si el estado es "COMPLETED".
 */
export function isPaymentCompleted(payment) {
  return payment && payment.status === 'COMPLETED';
}

/**
 * Registro de eventos con tipo y contexto específico para BitHelping.
 * @param {string} type - Tipo de mensaje ('info', 'warn', 'error').
 * @param {string} message - Mensaje a registrar.
 */
export function logMessage(type, message) {
  const timestamp = new Date().toISOString();
  console[type](`[${timestamp}] [BitHelping]: ${message}`);
}

