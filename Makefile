all    :; @forge build
clean  :; @forge clean
test   :; @forge test
fmt    :; @forge fmt

dry-run:; @forge script script/Deploy.s.sol:DeployScript
deploy :; @forge script script/Deploy.s.sol:DeployScript --broadcast --verify

migrate:; @forge script script/Migrate.s.sol:MigrateScript --sender 0x08837De0Ae21C270383D9F2de4DB03c7b1314632 -vvvv

.PHONY: all flat clean test salt deploy
