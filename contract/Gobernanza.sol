// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBITH {
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingGovernance {
    struct Proposal {
        string description; // Descripción de la propuesta
        uint256 votesFor;   // Votos a favor
        uint256 votesAgainst; // Votos en contra
        uint256 startTime;  // Tiempo de inicio de la votación
        uint256 endTime;    // Tiempo de finalización de la votación
        bool executed;      // Estado de ejecución de la propuesta
        mapping(address => bool) hasVoted; // Seguimiento de votos por usuario
    }

    IBITH public bithToken; // Interfaz del token BITH
    address public admin; // Dirección del administrador
    uint256 public proposalCount; // Número total de propuestas

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed proposalId, string description, uint256 startTime, uint256 endTime);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 votingPower);
    event ProposalExecuted(uint256 indexed proposalId, bool success);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor(address _bithToken) {
        require(_bithToken != address(0), "Invalid token address");
        bithToken = IBITH(_bithToken);
        admin = msg.sender;
    }

    /// @notice Crear una nueva propuesta
    /// @param description Descripción de la propuesta
    /// @param votingPeriod Duración de la votación en segundos
    function createProposal(string memory description, uint256 votingPeriod) external onlyAdmin {
        require(votingPeriod > 0, "Voting period must be greater than 0");

        Proposal storage newProposal = proposals[proposalCount++];
        newProposal.description = description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + votingPeriod;

        emit ProposalCreated(proposalCount - 1, description, newProposal.startTime, newProposal.endTime);
    }

    /// @notice Votar en una propuesta
    /// @param proposalId ID de la propuesta
    /// @param support Votar a favor (true) o en contra (false)
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting period has not started");
        require(block.timestamp <= proposal.endTime, "Voting period has ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 votingPower = bithToken.balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");

        if (support) {
            proposal.votesFor += votingPower;
        } else {
            proposal.votesAgainst += votingPower;
        }

        proposal.hasVoted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, support, votingPower);
    }

    /// @notice Ejecutar una propuesta si ha sido aprobada
    /// @param proposalId ID de la propuesta
    function executeProposal(uint256 proposalId) external onlyAdmin {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting period has not ended");
        require(!proposal.executed, "Proposal already executed");

        // La propuesta se aprueba si los votos a favor son mayores que los votos en contra
        bool success = proposal.votesFor > proposal.votesAgainst;
        proposal.executed = true;

        emit ProposalExecuted(proposalId, success);

        // Aquí puedes agregar lógica para realizar acciones basadas en el éxito de la propuesta.
    }

    /// @notice Obtener detalles de una propuesta
    /// @param proposalId ID de la propuesta
    /// @return description, votesFor, votesAgainst, startTime, endTime, executed
    function getProposalDetails(uint256 proposalId)
        external
        view
        returns (
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 startTime,
            uint256 endTime,
            bool executed
        )
    {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.startTime,
            proposal.endTime,
            proposal.executed
        );
    }
}

