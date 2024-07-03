all    :; @forge build
clean  :; @forge clean
test   :; @forge test
fmt    :; @forge fmt

dry-run:; @forge script script/Deploy.s.sol:DeployScript --rpc-url "https://koi-rpc.darwinia.network"
deploy :; @forge script script/Deploy.s.sol:DeployScript --rpc-url "https://koi-rpc.darwinia.network"  --broadcast

.PHONY: all flat clean test salt deploy
