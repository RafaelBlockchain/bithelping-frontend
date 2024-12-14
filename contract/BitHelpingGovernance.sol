// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the BHELP Token (BEP20 Token)
interface IBHELP {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

contract BitHelpingGovernance {
    address public owner;
    IBHELP public bhelpToken;

    struct Proposal {
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 endTime;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;
    uint256 public votingPeriod = 3 days; // Voting period (3 days)
    uint256 public quorumPercentage = 10; // Minimum percentage of total supply needed to reach quorum

    event ProposalCreated(uint256 proposalId, address proposer, string description, uint256 endTime);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Owner only");
        _;
    }

    modifier hasVotingPower() {
        require(bhelpToken.balanceOf(msg.sender) > 0, "You must hold tokens to vote");
        _;
    }

    modifier proposalExists(uint256 proposalId) {
        require(proposals[proposalId].endTime > 0, "Proposal does not exist");
        _;
    }

    modifier hasNotVoted(uint256 proposalId) {
        require(!hasVoted[msg.sender][proposalId], "You have already voted on this proposal");
        _;
    }

    modifier votingOpen(uint256 proposalId) {
        require(block.timestamp < proposals[proposalId].endTime, "Voting period has ended");
        _;
    }

    modifier votingClosed(uint256 proposalId) {
        require(block.timestamp >= proposals[proposalId].endTime, "Voting period is still open");
        _;
    }

    constructor(address _bhelpToken) {
        owner = msg.sender;
        bhelpToken = IBHELP(_bhelpToken);
    }

    function createProposal(string memory _description) external hasVotingPower returns (uint256) {
        uint256 endTime = block.timestamp + votingPeriod;
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposer: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            endTime: endTime
        });

        emit ProposalCreated(proposalCount, msg.sender, _description, endTime);
        return proposalCount;
    }

    function vote(uint256 proposalId, bool _vote) external hasVotingPower proposalExists(proposalId) hasNotVoted(proposalId) votingOpen(proposalId) {
        Proposal storage proposal = proposals[proposalId];

        uint256 voterWeight = bhelpToken.balanceOf(msg.sender);

        if (_vote) {
            proposal.votesFor += voterWeight;
        } else {
            proposal.votesAgainst += voterWeight;
        }

        hasVoted[msg.sender][proposalId] = true;
        emit Voted(proposalId, msg.sender, _vote);
    }

    function executeProposal(uint256 proposalId) external proposalExists(proposalId) votingClosed(proposalId) {
        Proposal storage proposal = proposals[proposalId];

        require(!proposal.executed, "Proposal already executed");

        // Check quorum
        uint256 quorum = (bhelpToken.totalSupply() * quorumPercentage) / 100;
        require(proposal.votesFor + proposal.votesAgainst >= quorum, "Quorum not reached");

        bool success = false;
        if (proposal.votesFor > proposal.votesAgainst) {
            success = true;
        }

        proposal.executed = true;
        emit ProposalExecuted(proposalId, success);

        // Add logic to execute the proposal if successful (e.g., update project parameters)
    }

    function setVotingPeriod(uint256 _votingPeriod) external onlyOwner {
        votingPeriod = _votingPeriod;
    }

    function setQuorumPercentage(uint256 _quorumPercentage) external onlyOwner {
        quorumPercentage = _quorumPercentage;
    }
}

