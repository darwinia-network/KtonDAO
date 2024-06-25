// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IRewardsDistributionRecipient.sol";
import "./interfaces/IStakingRewards.sol";
import "./interfaces/IOldStakingRewards.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

contract KtonDAOVault is Initializable, Ownable2StepUpgradeable {
    // "modlda/trsry" in bytes.
    address public constant SYSTEM_PALLET = 0x6D6f646c64612f74727372790000000000000000;

    address public constant OLD_KTON_STAKING_REWARDS = 0x000000000419683a1a03AbC21FC9da25fd2B4dD7;
    address public constant OLD_KTON_REWARDS_DISTRIBUTION = 0x000000000Ae5DB7BDAf8D071e680452e33d91Dd5;

    address public stakingRewards;

    modifier onlySystem() {
        require(msg.sender == SYSTEM_PALLET, "Caller is not RewardsDistribution contract");
        _;
    }

    function initialize(address dao, address stakingReward_) public initializer {
        stakingRewards = stakingReward_;
        __Ownable_init(dao);
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    receive() external payable {}

    /// Runtime migration Step:
    /// 1. Migrate OLD_KTON_REWARDS_DISTRIBUTION's owner to this contracts address.
    /// 2. distributeRewards to this contract address.
    /// Note: The amount of the reward must be passed in via msg.value.
    function distributeRewards() external payable onlySystem returns (bool) {
        uint256 reward = msg.value;
        require(reward > 0, "Nothing to distribute");
        require(
            address(this).balance >= reward, "RewardsDistribution contract does not have enough tokens to distribute"
        );

        uint256 oldTotalSupply = IOldStakingRewards(OLD_KTON_STAKING_REWARDS).totalSupply();
        uint256 newTotalSupply = IStakingRewards(stakingRewards).underlyingTotalSupply();
        uint256 totalSupply = oldTotalSupply + newTotalSupply;

        if (totalSupply == 0) {
            return true;
        }

        uint256 oldReward = reward * oldTotalSupply / totalSupply;
        uint256 newReward = reward - oldReward;

        if (oldReward > 0) {
            IRewardsDistributionRecipient(OLD_KTON_REWARDS_DISTRIBUTION).notifyRewardAmount{value: oldReward}();
            emit RewardsDistributed(OLD_KTON_REWARDS_DISTRIBUTION, oldReward);
        }

        if (newReward > 0) {
            IRewardsDistributionRecipient(stakingRewards).notifyRewardAmount{value: newReward}();
            emit RewardsDistributed(stakingRewards, newReward);
        }

        return true;
    }

    event RewardsDistributed(address stakingRewards, uint256 amount);
}
