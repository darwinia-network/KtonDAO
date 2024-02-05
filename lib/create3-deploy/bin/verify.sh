#!/usr/bin/env bash

set -eo pipefail

create3=0x0000000000C76fe1798a428F60b27c6724e03408

verify() {
  local addr; addr=$1
  local path; path=$2
  local name; name=${path#*:}
  (set -x; forge verify-contract \
    --num-of-optimizations 999999 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version v0.8.17+commit.8df45f5f \
    --show-standard-json-input \
    $addr \
    $path > script/$name.v.json)
}

verify $create3 src/CREATE3Factory.sol:CREATE3Factory
