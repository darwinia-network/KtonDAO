pragma solidity ^0.5.16;

contract RewardsDistributionRecipient {
    address public rewardsDistribution;

    function notifyRewardAmount() external payable;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}
