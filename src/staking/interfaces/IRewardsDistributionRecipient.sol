pragma solidity >=0.4.24;

interface IRewardsDistributionRecipient {
    function notifyRewardAmount() external payable;
}
