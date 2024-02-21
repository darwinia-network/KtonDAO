#!/usr/bin/env bash

set -eo pipefail

chain=${1:?}
addr=0x0000004B21061Ce4C13138C41c3ad694500129cc
salt=0x65fd4e09846a2c80c9661aea1c7662ec870ec1814392afcf88b4454be0e1ce17
c3=0x0000000000C76fe1798a428F60b27c6724e03408
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

bytecode=0x$(jq -r ".contracts[\"src/KTONStakingRewards.sol\"].KTONStakingRewards.evm.bytecode.object" out/dapp.sol.json)
# salt, creationCode
expect_addr=$(seth call $c3 "deploy(bytes32,bytes)(address)" $salt $bytecode --chain $chain)

if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${expect_addr}") ]]; then
  (set -x; seth send $c3 "deploy(bytes32,bytes)" $salt $bytecode --chain $chain)
else
  echo "Unexpected address."
fi
