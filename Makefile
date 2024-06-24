all    :; @forge build
clean  :; @forge clean
test   :; @forge test

fmt    :; @forge fmt
salt   :; @create3 -s 00000000000000
deploy :; @bash ./bin/deploy.sh $(chain)

.PHONY: all flat clean test salt deploy
