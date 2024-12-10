// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract BitHelpingGovernance {
    address public owner;
    IBITH public bithToken;

    uint256 public proposalId;
    uint256 public quorumPercentage = 50; // 50% de votos necesarios para aprobar una propuesta

    struct Proposal {
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 totalVotes;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public stakes;

    event ProposalCreated(uint256 proposalId, address proposer, string description);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyStakeholders() {
        require(bithToken.balanceOf(msg.sender) > 0, "You must hold BITH tokens to vote");
        _;
    }

    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId < proposalId, "Proposal does not exist");
        _;
    }

    modifier notVoted(uint256 _proposalId) {
        require(!proposals[_proposalId].voted[msg.sender], "You have already voted on this proposal");
        _;
    }

    constructor(address _bithToken) {
        owner = msg.sender;
        bithToken = IBITH(_bithToken);
    }

    // Crear una propuesta
    function createProposal(string memory _description) external onlyStakeholders {
        uint256 newProposalId = proposalId++;
        Proposal storage newProposal = proposals[newProposalId];

        newProposal.proposer = msg.sender;
        newProposal.description = _description;

        emit ProposalCreated(newProposalId, msg.sender, _description);
    }

    // Votar sobre una propuesta
    function vote(uint256 _proposalId, bool _vote) external onlyStakeholders proposalExists(_proposalId) notVoted(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        uint256 voterTokens = bithToken.balanceOf(msg.sender);
        require(voterTokens > 0, "You must have tokens to vote");

        if (_vote) {
            proposal.votesFor += voterTokens;
        } else {
            proposal.votesAgainst += voterTokens;
        }

        proposal.voted[msg.sender] = true;
        proposal.totalVotes += voterTokens;

        emit Voted(_proposalId, msg.sender, _vote);
    }

    // Ejecutar la propuesta si cumple con los requisitos de votos
    function executeProposal(uint256 _proposalId) external proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        // Solo el creador de la propuesta o el propietario puede ejecutarla
        require(msg.sender == proposal.proposer || msg.sender == owner, "Not authorized to execute");

        // Verificar si se alcanzó el quorum
        uint256 totalSupply = bithToken.balanceOf(address(this)); // Suponiendo que el contrato tenga tokens
        uint256 requiredVotes = (totalSupply * quorumPercentage) / 100;

        require(proposal.totalVotes >= requiredVotes, "Quorum not reached");

        if (proposal.votesFor > proposal.votesAgainst) {
            // Ejecutar la acción propuesta, esto podría ser cualquier acción, como actualización de contrato, distribución, etc.
            // Ejemplo: se puede actualizar una variable, cambiar tarifas, etc.
            // Aquí solo emitimos un evento como ejemplo.
            proposal.executed = true;

            // Acción que ejecuta la propuesta
            // _executeProposalAction();

            emit ProposalExecuted(_proposalId, true);
        } else {
            emit ProposalExecuted(_proposalId, false);
        }
    }

    // Función de emergencia para que el propietario retire los tokens BITH del contrato
    function withdrawBITH(uint256 amount) external onlyOwner {
        require(bithToken.transfer(owner, amount), "Transfer failed");
    }

    // Función para actualizar el quorum (porcentaje necesario para aprobar una propuesta)
    function updateQuorumPercentage(uint256 _quorumPercentage) external onlyOwner {
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum percentage");
        quorumPercentage = _quorumPercentage;
    }

    // Función para obtener el estado de una propuesta
    function getProposalStatus(uint256 _proposalId) external view proposalExists(_proposalId) returns (string memory status) {
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.executed) {
            return "Executed";
        }

        if (proposal.votesFor > proposal.votesAgainst && proposal.totalVotes >= (bithToken.balanceOf(address(this)) * quorumPercentage) / 100) {
            return "Passed";
        }

        return "Pending";
    }
}

