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

distribution_addr=0x000000881a7E196362ad7B20Dbd3cD4E8B54aF67
distribution_salt=0x4fb8902f10a7f049221dbac31d592917935cbb5b51310017ae39456af3ba716c
# "sc/ktstk" in bytes.
distribution_owner=0x73632F6B7473746B000000000000000000000000;

distribution_bytecode=$(jq -r ".contracts[\"src/RewardsDistribution.sol\"].RewardsDistribution.evm.bytecode.object" out/dapp.sol.json)
distribution_args=$(set -x; ethabi encode params \
  -v address "${distribution_owner:2}"
)
distribution_creationCode=0x$distribution_bytecode$distribution_args

deploy $distribution_addr $distribution_salt $distribution_creationCode 

staker_addr=0x00000045CCC2bAf529Ec03AcBa349b2c25D44EEa
staker_salt=0x242468e58063bebed22cd5e85693d4ef4bb2dcf27c20c0f396e4a7d11030b222
staker_bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
staker_args=$(set -x; ethabi encode params \
  -v address "${distribution_addr:2}"
)
staker_creationCode=0x$staker_bytecode$staker_args

deploy $staker_addr $staker_salt $staker_creationCode
