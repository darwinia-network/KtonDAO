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

distribution_addr=0x0000000B7525fcC81AF34f25eFc4e87A0beaCDEd
distribution_salt=0xa84a08f1f27355050292c161c24270ec58f78e9f4c5f22c42bc615eea15dbde0
# "sc/ktstk" in bytes.
distribution_owner=0x73632F6B7473746B000000000000000000000000;

distribution_bytecode=$(jq -r ".contracts[\"src/RewardsDistribution.sol\"].RewardsDistribution.evm.bytecode.object" out/dapp.sol.json)
distribution_args=$(set -x; ethabi encode params \
  -v address "${distribution_owner:2}"
)
distribution_creationCode=0x$distribution_bytecode$distribution_args

deploy $distribution_addr $distribution_salt $distribution_creationCode 

staker_addr=0x0000008DF497D85E3C16d6A56dAA070277e102c0
staker_salt=0x6d9f3dc3c5752f7dc1add87465c17dfb03fd0c0e058a2b914eec5d3b9cb3e136
staker_bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
staker_args=$(set -x; ethabi encode params \
  -v address "${distribution_addr:2}"
)
staker_creationCode=0x$staker_bytecode$staker_args

deploy $staker_addr $staker_salt $staker_creationCode
