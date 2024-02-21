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

distribution_addr=0x00000012683ac5ff103025368AF1F81Fc115EfF0
distribution_salt=0xcad6cb652297b9cce31cc6c6ab19511394175643c4551d0974b9fe5cde811818
# "sc/ktnstk" in bytes.
distribution_owner=0x73632F6b746e73746B0000000000000000000000;

distribution_bytecode=$(jq -r ".contracts[\"src/RewardsDistribution.sol\"].RewardsDistribution.evm.bytecode.object" out/dapp.sol.json)
distribution_args=$(set -x; ethabi encode params \
  -v address "${distribution_owner:2}"
)
distribution_creationCode=0x$distribution_bytecode$distribution_args

deploy $distribution_addr $distribution_salt $distribution_creationCode 

staker_addr=0x0000009174453855101ad2D7981E2fC4222B5ad2
staker_salt=0xa2a87b8f359c9a1951d7639f04b027a94fe687f785b285ad32a91d30ac396666
staker_bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
staker_args=$(set -x; ethabi encode params \
  -v address "${distribution_addr:2}"
)
staker_creationCode=0x$staker_bytecode$staker_args

deploy $staker_addr $staker_salt $staker_creationCode
