// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract RewardsDistributionRecipient {
    address public rewardsDistribution;

    function notifyRewardAmount() external payable;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}
