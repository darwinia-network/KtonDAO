## Staker

Forked from 
[https://github.com/Uniswap/liquidity-staker](https://github.com/Uniswap/liquidity-staker)

Staking pool for KTON. 

## Addresses
|  NetWork  |       KTONStakingRewards                   |           RewardsDistribution              | 
|-----------|--------------------------------------------|--------------------------------------------|
|  Pangolin | 0x0000004ECebC4FCC2B5537Be6f0731Ad49D96D9c | 0x00000049A769D69Fc5E7eB2B45e02Bc1551f741C |

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
