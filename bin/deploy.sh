#!/usr/bin/env bash

set -eo pipefail

chain=${1:?}
c3=0x0000000000C76fe1798a428F60b27c6724e03408
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

deploy() {
  local addr=${1:?}
  local salt=${2:?}
  local bytecode=${3:?}
  expect_addr=$(seth call $c3 "deploy(bytes32,bytes)(address)" $salt $bytecode --chain $chain)

  if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${expect_addr}") ]]; then
    (set -x; seth send $c3 "deploy(bytes32,bytes)" $salt $bytecode --chain $chain)
  else
    echo "Unexpected address."
  fi
}

distribution_addr=0x00000049A769D69Fc5E7eB2B45e02Bc1551f741C
distribution_salt=0x27b58878fc24bfd82636938cacd4c93f4365ddf970f0546fe52a756b7ffe8bf5
# "sc/ktnstk" in bytes.
# distribution_owner=0x73632F6b746e73746B0000000000000000000000;
distribution_owner=$deployer

distribution_bytecode=$(jq -r ".contracts[\"src/RewardsDistribution.sol\"].RewardsDistribution.evm.bytecode.object" out/dapp.sol.json)
distribution_args=$(set -x; ethabi encode params \
  -v address "${distribution_owner:2}"
)
distribution_creationCode=0x$distribution_bytecode$distribution_args

deploy $distribution_addr $distribution_salt $distribution_creationCode 

staker_addr=0x0000004ECebC4FCC2B5537Be6f0731Ad49D96D9c
staker_salt=0xbb005a3084eed043ef17394e9343cb89c5e2ffc02658565e0748279edb9030dc
staker_bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
staker_args=$(set -x; ethabi encode params \
  -v address "${distribution_addr:2}"
)
staker_creationCode=0x$staker_bytecode$staker_args

deploy $staker_addr $staker_salt $staker_creationCode
