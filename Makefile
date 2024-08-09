all    :; @forge build
clean  :; @forge clean
test   :; @forge test
fmt    :; @forge fmt

dry-run:; @forge script script/Deploy.s.sol:DeployScript
deploy :; @forge script script/Deploy.s.sol:DeployScript --broadcast --verify

.PHONY: all flat clean test salt deploy
