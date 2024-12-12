import { WalletConnectConnector } from "@web3-react/walletconnect-connector";

// Configuración del conector de WalletConnect
export const walletConnect = new WalletConnectConnector({
  rpc: {
    1: "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID", // Reemplaza con tu proyecto Infura o un RPC compatible
    137: "https://polygon-rpc.com", // RPC para Polygon
  },
  bridge: "https://bridge.walletconnect.org",
  qrcode: true,
});

