all    :; source .env.local && dapp --use solc:0.8.20 build
flat   :; source .env.local && dapp --use solc:0.8.20 flat
clean  :; dapp clean
test   :; dapp test

fmt    :; @forge fmt
salt   :; @create3 -s 00000000000000
deploy :; @bash ./bin/deploy.sh $(chain)

.PHONY: all flat clean test salt deploy
