
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public totalRaised;
    uint256 public deadline;

    mapping(address => uint256) public contributions;
    address[] public contributors;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event RefundIssued(address indexed contributor, uint256 amount);

    constructor(uint256 _goal, uint256 _durationInDays) {
        require(_goal > 0, "Goal must be greater than 0");
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline has passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached");
        _;
    }

    function contribute() external payable beforeDeadline {
        require(msg.value > 0, "Contribution must be greater than 0");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyOwner afterDeadline {
        require(totalRaised >= goal, "Goal not reached");

        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    function requestRefund() external afterDeadline {
        require(totalRaised < goal, "Goal was met, no refunds");

        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions found");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RefundIssued(msg.sender, amount);
    }

    function checkBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getGoal() external view returns (uint256) {
        return goal;
    }

    function getTotalRaised() external view returns (uint256) {
        return totalRaised;
    }

    function getDeadline() external view returns (uint256) {
        return deadline;
    }

    function getTimeLeft() external view returns (uint256) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    function getContractInfo() external view returns (
        address _owner,
        uint256 _goal,
        uint256 _raised,
        uint256 _balance,
        uint256 _deadline
    ) {
        return (owner, goal, totalRaised, address(this).balance, deadline);
    }

    function getAllContributors() external view returns (address[] memory, uint256[] memory) {
        uint256[] memory amounts = new uint256[](contributors.length);
        for (uint i = 0; i < contributors.length; i++) {
            amounts[i] = contributions[contributors[i]];
        }
        return (contributors, amounts);
    }

    function getPercentageRaised() external view returns (uint256) {
        if (goal == 0) return 0;
        return (totalRaised * 10000) / goal; // basis points (e.g., 6523 = 65.23%)
    }

    function getCampaignStatus() external view returns (string memory) {
        if (block.timestamp < deadline) {
            return "Active";
        } else if (totalRaised >= goal) {
            return "Successful";
        } else {
            return "Failed";
        }
    }

    fallback() external payable {
        totalRaised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    receive() external payable {
        totalRaised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }
}

