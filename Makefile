all    :; @forge build
clean  :; @forge clean
test   :; @forge test
fmt    :; @forge fmt

dry-run:; @forge script script/DeployKoi.s.sol:DeployKoiScript --rpc-url "https://koi-rpc.darwinia.network"
deploy :; @forge script script/DeployKoi.s.sol:DeployKoiScript --rpc-url "https://koi-rpc.darwinia.network"  --broadcast

.PHONY: all flat clean test salt deploy
