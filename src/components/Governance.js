import React, { useState } from "react";

const Governance = ({ contract }) => {
  const [proposals, setProposals] = useState([]);
  const [newProposal, setNewProposal] = useState("");

  const fetchProposals = async () => {
    const proposalList = await contract.methods.getProposals().call();
    setProposals(proposalList);
  };

  const createProposal = async () => {
    await contract.methods.createProposal(newProposal).send({ from: account });
    fetchProposals();
  };

  return (
    <div>
      <h2>Propuestas</h2>
      <input
        type="text"
        placeholder="Nueva propuesta"
        value={newProposal}
        onChange={(e) => setNewProposal(e.target.value)}
      />
      <button onClick={createProposal}>Crear Propuesta</button>
      <ul>
        {proposals.map((proposal, index) => (
          <li key={index}>{proposal}</li>
        ))}
      </ul>
    </div>
  );
};

export default Governance;

