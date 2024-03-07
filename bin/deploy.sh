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

distribution_addr=0x000000000Ae5DB7BDAf8D071e680452e33d91Dd5
distribution_salt=0x56641813759e8bb0f38c11807e246deaa9220254aafb00ae22942afcc7679c4d
# "modlda/trsry" in bytes.
distribution_owner=0x6d6f646c64612f74727372790000000000000000

distribution_bytecode=$(jq -r ".contracts[\"src/RewardsDistribution.sol\"].RewardsDistribution.evm.bytecode.object" out/dapp.sol.json)
distribution_args=$(set -x; ethabi encode params \
  -v address "${distribution_owner:2}"
)
distribution_creationCode=0x$distribution_bytecode$distribution_args

deploy $distribution_addr $distribution_salt $distribution_creationCode 

staker_addr=0x000000000419683a1a03AbC21FC9da25fd2B4dD7
staker_salt=0x1b89d0d4a580239b6114288d498565d6485466cd5b6c28a42f79dc9d3fcd3be0
staker_bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
staker_args=$(set -x; ethabi encode params \
  -v address "${distribution_addr:2}"
)
staker_creationCode=0x$staker_bytecode$staker_args

deploy $staker_addr $staker_salt $staker_creationCode
