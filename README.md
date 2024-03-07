## Staker

Forked from 
[https://github.com/Uniswap/liquidity-staker](https://github.com/Uniswap/liquidity-staker)

Staking pool for KTON. 

## Addresses
|  Contract            | Canonical Cross-chain Deployment Address   |
|----------------------|--------------------------------------------|
|  KTONStakingRewards  | 0x000000000419683a1a03AbC21FC9da25fd2B4dD7 |
|  RewardsDistribution | 0x000000000Ae5DB7BDAf8D071e680452e33d91Dd5 |
|  modlda/trsry        | 0x6d6f646c64612f74727372790000000000000000 |

### API

#### `totalSupply()` 
Return the total KTON token amount in the staking pool

#### `balanceOf(address account)`
Return the KTON token balance of `account`

#### `earned(address account)`
Return the earned RING amount of `account`

#### `stake(uint256 amount)`
Stake `amount` KTON token for receiving RING reward

#### `withdraw(uint256 amount)`
Withdraw `amount` KTON token

#### `getReward()`
Claim earned RING

#### `exit()`
Withdraw all staked KTON token and Claim earned RING to exit

### [Mathematical Proof](./doc/staker.pdf)
