// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IRewardsDistributionRecipient.sol";
import "./interfaces/IOldRewardsDistributionRecipient.sol";
import "./interfaces/IStakingRewards.sol";
import "./interfaces/IOldStakingRewards.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

/// @custom:oz-upgrades-from KtonDAOVault
contract KtonDAOVaultV2 is Initializable, Ownable2StepUpgradeable {
    // "modlda/trsry" in bytes.
    address public constant SYSTEM_PALLET = 0x6D6f646c64612f74727372790000000000000000;

    address public constant OLD_KTON_STAKING_REWARDS = 0x000000000419683a1a03AbC21FC9da25fd2B4dD7;
    address public constant OLD_KTON_REWARDS_DISTRIBUTION = 0x000000000Ae5DB7BDAf8D071e680452e33d91Dd5;
    address payable public constant KTON_DAO_TIMELOCK = payable(0x08837De0Ae21C270383D9F2de4DB03c7b1314632);

    address public stakingRewards;

    modifier onlySystem() {
        require(msg.sender == SYSTEM_PALLET, "Caller is not RewardsDistribution contract");
        _;
    }

    // function initializeV2() public reinitializer(2) {
    //     uint256 rewards = OLD_KTON_REWARDS_DISTRIBUTION.balance;
    //     IOldRewardsDistributionRecipient(OLD_KTON_REWARDS_DISTRIBUTION).distributeRewards(
    //         OLD_KTON_STAKING_REWARDS, rewards
    //     );
    //     emit RewardsDistributed(OLD_KTON_REWARDS_DISTRIBUTION, rewards);
    // }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    receive() external payable {}

    /// Note: The amount of the reward must be passed in via msg.value.
    function distributeRewards() external payable onlySystem returns (bool) {
        uint256 reward = msg.value;
        require(reward > 0, "Nothing to distribute");
        require(
            address(this).balance >= reward, "RewardsDistribution contract does not have enough tokens to distribute"
        );

        uint256 rewardToTimelock = reward * 20 / 100;
        uint256 rewardToStaking = reward - rewardToTimelock;

        uint256 oldTotalSupply = IOldStakingRewards(OLD_KTON_STAKING_REWARDS).totalSupply();
        uint256 newTotalSupply = IStakingRewards(stakingRewards).underlyingTotalSupply();
        uint256 totalSupply = oldTotalSupply + newTotalSupply;

        if (totalSupply == 0) {
            _distributeToTimelock(reward);
            return true;
        }

        uint256 oldReward = rewardToStaking * oldTotalSupply / totalSupply;
        uint256 newReward = rewardToStaking - oldReward;

        _distributeToTimelock(rewardToTimelock);

        if (oldReward > 0) {
            IOldRewardsDistributionRecipient(OLD_KTON_REWARDS_DISTRIBUTION).distributeRewards{value: oldReward}(
                OLD_KTON_STAKING_REWARDS, oldReward
            );
            emit RewardsDistributed(OLD_KTON_REWARDS_DISTRIBUTION, oldReward);
        }

        if (newReward > 0) {
            IRewardsDistributionRecipient(stakingRewards).notifyRewardAmount{value: newReward}();
            emit RewardsDistributed(stakingRewards, newReward);
        }

        return true;
    }

    function _distributeToTimelock(uint256 reward) internal {
        if (reward > 0) {
            KTON_DAO_TIMELOCK.transfer(reward);
            emit RewardsDistributed(KTON_DAO_TIMELOCK, reward);
        }
    }

    event RewardsDistributed(address stakingRewards, uint256 amount);
}
