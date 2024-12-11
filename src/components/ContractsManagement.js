import React from "react";

const ContractsManagement = ({ contract }) => {
  const updateContractAddress = async (contractType, address) => {
    await contract.methods[`update${contractType}Contract`](address).send({ from: window.ethereum.selectedAddress });
    alert(`${contractType} actualizado correctamente.`);
  };

  return (
    <div>
      <h3>Administrar Contratos Integrados</h3>
      <input type="text" placeholder="Nuevo contrato de Staking" id="stakingAddress" />
      <button onClick={() => updateContractAddress("Staking", document.getElementById("stakingAddress").value)}>
        Actualizar Staking
      </button>
    </div>
  );
};

export default ContractsManagement;

