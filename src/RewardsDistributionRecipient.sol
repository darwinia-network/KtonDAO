pragma solidity ^0.5.16;

contract RewardsDistributionRecipient {
    // "sc/ktnstk" in bytes.
    address public constant rewardsDistribution = 0x73632F6b746e73746B0000000000000000000000;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}
