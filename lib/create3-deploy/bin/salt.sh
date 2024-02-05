#! /usr/bin/env bash

set -eo pipefail

create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7

out_dir=$PWD/out
init_code=$(jq -r '.bytecode.object' $out_dir/CREATE3Factory.sol/CREATE3Factory.json)

out=$(cast create2 -i $init_code -d $create2 --starts-with "0000000000" | grep -E '(Address:|Salt:)')
addr=$(echo $out | awk '{print $2}' )
salt=$(cast --to-uint256 $(echo $out | awk '{print $4}' ))
echo -e "CREATE3Factory: \n Address: $addr \n Salt:    $salt"
