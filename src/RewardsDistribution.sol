pragma solidity ^0.5.16;

import "./Owned.sol";
import "./interfaces/IRewardsDistributionRecipient.sol";

contract RewardsDistribution is Owned {
    constructor(address _owner) public Owned(_owner) {}

    function() external payable {}

    function distributeRewards(address ktonStakingRewards, uint256 reward) external payable onlyOwner returns (bool) {
        require(reward > 0, "Nothing to distribute");
        require(
            address(this).balance >= reward, "RewardsDistribution contract does not have enough tokens to distribute"
        );
        IRewardsDistributionRecipient(ktonStakingRewards).notifyRewardAmount.value(reward)();
        emit RewardsDistributed(reward);
        return true;
    }

    event RewardsDistributed(uint256 amount);
}
