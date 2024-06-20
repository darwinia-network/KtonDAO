// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Owned.sol";
import "./interfaces/IRewardsDistributionRecipient.sol";

contract RewardsDistribution is Owned {
    constructor(address _owner) Owned(_owner) {}

    receive() external payable {}

    function distributeRewards(address ktonStakingRewards, uint256 reward) external payable onlyOwner returns (bool) {
        require(reward > 0, "Nothing to distribute");
        require(
            address(this).balance >= reward, "RewardsDistribution contract does not have enough tokens to distribute"
        );
        IRewardsDistributionRecipient(ktonStakingRewards).notifyRewardAmount{value: reward}();
        emit RewardsDistributed(ktonStakingRewards, reward);
        return true;
    }

    event RewardsDistributed(address stakingRewards, uint256 amount);
}
