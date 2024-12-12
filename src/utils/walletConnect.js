// src/utils/walletConnect.js
export const walletConnect = async (setWeb3, setAccount, setContract, setLiquidityContract) => {
  if (window.ethereum) {
    try {
      const web3Instance = new Web3(window.ethereum);
      setWeb3(web3Instance);

      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);

      const bitHelpingContract = new web3Instance.eth.Contract(BitHelpingABI, CONTRACT_ADDRESS);
      setContract(bitHelpingContract);

      const bitHelpingLiquidityContract = new web3Instance.eth.Contract(BitHelpingLiquidityABI, LIQUIDITY_CONTRACT_ADDRESS);
      setLiquidityContract(bitHelpingLiquidityContract);
    } catch (error) {
      console.error("Error al conectar MetaMask:", error);
    }
  } else {
    alert("MetaMask no está instalada. Por favor, instala MetaMask y recarga la página.");
  }
};

