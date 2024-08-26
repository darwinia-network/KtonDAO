// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;

interface IOldRewardsDistributionRecipient {
    function distributeRewards(address ktonStakingRewards, uint256 reward) external payable returns (bool);
}
