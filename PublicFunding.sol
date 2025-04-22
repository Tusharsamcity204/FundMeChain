
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public totalRaised;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);

    constructor(uint256 _goal) {
        owner = msg.sender;
        goal = _goal;
    }

    function contribute() external payable {
        uint256 contribution = msg.value;
        require(contribution > 0, "Contribution must be greater than 0");
        totalRaised += contribution;
        emit ContributionReceived(msg.sender, contribution);
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(totalRaised >= goal, "Goal not reached");
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    function checkBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
