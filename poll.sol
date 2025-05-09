// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollDApp {
    struct Poll {
        uint256 id;
        address creator;
        string question;
        string[] options;
        uint256[] voteCounts;
        uint256 totalVotes;
        bool active;
        uint256 createdAt;
        uint256 expiresAt; // Expiry timestamp
    }

    uint256 private pollIdCounter;
    mapping(uint256 => Poll) public polls;
    uint256[] public allPollIds;
    mapping(address => mapping(uint256 => bool)) private hasVoted;

    event PollCreated(uint256 indexed pollId, address indexed creator, string question);
    event VoteCast(uint256 indexed pollId, uint256 optionIndex);
    event PollDeactivated(uint256 indexed pollId);

    // Create poll with expiry duration in seconds
    function createPoll(string memory _question, string[] memory _options, uint256 _duration) public {
        require(_options.length >= 2, "A poll needs at least 2 options");
        require(_options.length <= 10, "A poll cannot have more than 10 options");

        uint256 pollId = pollIdCounter++;
        uint256[] memory voteCounts = new uint256[](_options.length);
        
        polls[pollId] = Poll({
            id: pollId,
            creator: msg.sender,
            question: _question,
            options: _options,
            voteCounts: voteCounts,
            totalVotes: 0,
            createdAt: block.timestamp,
            active: true,
            expiresAt: block.timestamp + _duration
        });
        
        allPollIds.push(pollId);
        emit PollCreated(pollId, msg.sender, _question);
    }

    function vote(uint256 _pollId, uint256 _optionIndex) public {
        Poll storage poll = polls[_pollId];
        require(poll.active, "Poll is not active");
        require(block.timestamp < poll.expiresAt, "Poll has expired");
        require(_optionIndex < poll.options.length, "Invalid option");
        require(!hasVoted[msg.sender][_pollId], "You have already voted");

        poll.voteCounts[_optionIndex]++;
        poll.totalVotes++;
        hasVoted[msg.sender][_pollId] = true;

        emit VoteCast(_pollId, _optionIndex);
    }

    function deactivatePoll(uint256 _pollId) public {
        Poll storage poll = polls[_pollId];
        require(poll.active, "Poll already inactive");
        require(msg.sender == poll.creator, "Only creator can deactivate");
        poll.active = false;
        emit PollDeactivated(_pollId);
    }

    function getPoll(
        uint256 _pollId
    ) public view returns (
        uint256 id,
        address creator,
        string memory question,
        string[] memory options,
        uint256[] memory voteCounts,
        uint256 totalVotes,
        bool active,
        uint256 expiresAt
    ) {
        Poll storage poll = polls[_pollId];
        require(poll.active, "Poll does not exist or is not active");

        return (
            poll.id,
            poll.creator,
            poll.question,
            poll.options,
            poll.voteCounts,
            poll.totalVotes,
            poll.active,
            poll.expiresAt
        );
    }

    function getPollCount() public view returns (uint256) {
        return allPollIds.length;
    }

    function hasUserVoted(address _user, uint256 _pollId) public view returns (bool) {
        return hasVoted[_user][_pollId];
    }

    function resetAllPolls() public {
        for (uint256 i = 0; i < allPollIds.length; i++) {
            polls[allPollIds[i]].active = false;
        }
        delete allPollIds;
        pollIdCounter = 0;
    }

    function getLeaderboard() public view returns (uint256[] memory) {
        uint256[] memory pollIds = new uint256[](allPollIds.length);
        for (uint256 i = 0; i < allPollIds.length; i++) {
            pollIds[i] = allPollIds[i];
        }

        for (uint256 i = 0; i < pollIds.length; i++) {
            for (uint256 j = 0; j < pollIds.length - i - 1; j++) {
                if (polls[pollIds[j]].totalVotes < polls[pollIds[j + 1]].totalVotes) {
                    uint256 temp = pollIds[j];
                    pollIds[j] = pollIds[j + 1];
                    pollIds[j + 1] = temp;
                }
            }
        }

        return pollIds;
    }
}
