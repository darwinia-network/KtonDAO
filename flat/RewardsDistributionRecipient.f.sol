// hevm: flattened sources of src/RewardsDistributionRecipient.sol

pragma solidity >=0.5.16 <0.6.0;

////// src/RewardsDistributionRecipient.sol
/* pragma solidity ^0.5.16; */

contract RewardsDistributionRecipient {
    // "sc/ktnstk" in bytes.
    address public constant rewardsDistribution = 0x73632F6b746e73746B0000000000000000000000;

    function notifyRewardAmount() external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}

