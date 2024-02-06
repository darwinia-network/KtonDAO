#!/usr/bin/env bash

set -eo pipefail

chain=${1:?}
addr=0x000000000f681D85374225EdEeADC25560C1fb3F
salt=0xa4390aa887eb9fe9ed94283ed393bbfeb0b301e904fac48ba5d3c176f41851c1
c3=0x0000000000C76fe1798a428F60b27c6724e03408
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

KTON=0x0000000000000000000000000000000000000402
# STAKING_PALLET=0x6d6f646c64612f74727372790000000000000000
STAKING_PALLET=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

bytecode=$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
args=$(set -x; ethabi encode params \
  -v address "${STAKING_PALLET:2}" \
  -v address "${KTON:2}"
)
creationCode=0x$bytecode$args
# salt, creationCode
expect_addr=$(seth call $c3 "deploy(bytes32,bytes)(address)" $salt $creationCode --chain $chain)

if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${expect_addr}") ]]; then
  (set -x; seth send $c3 "deploy(bytes32,bytes)" $salt $creationCode --chain $chain)
else
  echo "Unexpected address."
fi
