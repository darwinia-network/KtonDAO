## Staker

Forked from 
[https://github.com/Uniswap/liquidity-staker](https://github.com/Uniswap/liquidity-staker)

Staking pool for KTON. 

## Addresses
|  NetWork  |       KTONStakingRewards                   |           RewardsDistribution              | 
|-----------|--------------------------------------------|--------------------------------------------|
|  Pangolin | 0x0000009174453855101ad2D7981E2fC4222B5ad2 | 0x00000012683ac5ff103025368AF1F81Fc115EfF0 |

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
