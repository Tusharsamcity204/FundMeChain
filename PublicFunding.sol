
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public totalRaised;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    constructor(uint256 _goal) {
        require(_goal > 0, "Goal must be greater than 0");
        owner = msg.sender;
        goal = _goal;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function contribute() external payable {
        uint256 contribution = msg.value;
        require(contribution > 0, "Contribution must be greater than 0");

        totalRaised += contribution;
        emit ContributionReceived(msg.sender, contribution);
    }

    function withdrawFunds() external onlyOwner {
        require(totalRaised >= goal, "Goal not reached");

        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    function checkBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 🔹 New: View goal
    function getGoal() external view returns (uint256) {
        return goal;
    }

    // 🔹 New: View total raised
    function getTotalRaised() external view returns (uint256) {
        return totalRaised;
    }

    // 🔹 New: Change the owner
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    // 🔹 New: Get all contract info in one call
    function getContractInfo() external view returns (address, uint256, uint256, uint256) {
        return (owner, goal, totalRaised, address(this).balance);
    }

    // 🔹 New: Accept plain Ether (fallback)
    fallback() external payable {
        totalRaised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    // 🔹 New: Accept Ether via receive()
    receive() external payable {
        totalRaised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }
}

