// hevm: flattened sources of src/RewardsDistribution.sol

pragma solidity >=0.4.24 >=0.5.16 <0.6.0;

////// src/Owned.sol
/* pragma solidity ^0.5.16; */


// https://github.com/Synthetixio/synthetix/blob/v2.27.2/contracts/Owned.sol 
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

////// src/interfaces/IRewardsDistributionRecipient.sol
/* pragma solidity >=0.4.24; */

interface IRewardsDistributionRecipient {
    function notifyRewardAmount() external payable;
}

////// src/RewardsDistribution.sol
/* pragma solidity ^0.5.16; */

/* import "./Owned.sol"; */
/* import "./interfaces/IRewardsDistributionRecipient.sol"; */

contract RewardsDistribution is Owned {
    constructor(address _owner) public Owned(_owner) {}

    function() external payable {}

    function distributeRewards(address ktonStakingRewards, uint256 reward) external payable onlyOwner returns (bool) {
        require(reward > 0, "Nothing to distribute");
        require(
            address(this).balance >= reward, "RewardsDistribution contract does not have enough tokens to distribute"
        );
        IRewardsDistributionRecipient(ktonStakingRewards).notifyRewardAmount.value(reward)();
        emit RewardsDistributed(ktonStakingRewards, reward);
        return true;
    }

    event RewardsDistributed(address stakingRewards, uint256 amount);
}

