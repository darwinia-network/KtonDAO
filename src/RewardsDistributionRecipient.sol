pragma solidity ^0.5.16;

contract RewardsDistributionRecipient {
    // "KTONStakingRewards" in bytes.
    address public constant rewardsDistribution = 0x4b544f4e5374616b696e67526577617264730000;

    function notifyRewardAmount() external payable;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}
