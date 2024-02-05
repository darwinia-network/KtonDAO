.PHONY: all fmt clean test salt install
.PHONY: tools foundry sync verify c3

-include .env

all    :; @forge build --force
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test
deploy :; @forge script script/Deploy.s.sol:Deploy --chain-id ${chain-id} --legacy --broadcast --verify
install:; @cargo install --path ./cli
sync   :; @git submodule update --recursive

tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash

salt   :; @bash ./bin/salt.sh
c3     :; @create3 -s 0000000000
verify :; @./bin/verify.sh
