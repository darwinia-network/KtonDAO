.PHONY: all fmt clean test salt
.PHONY: tools foundry sync create3

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test
deploy :; @forge script script/Deploy.s.sol:Deploy --chain ${chain-id} --broadcast --verify

salt   :; @create3 -s 000000000000
sync   :; @git submodule update --recursive
create3:; @cargo install --git https://github.com/darwinia-network/create3-deploy -f

tools  :  foundry create3
foundry:; curl -L https://foundry.paradigm.xyz | bash
