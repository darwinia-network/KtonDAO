all    :; source .env.local && dapp --use solc:0.5.16 build
flat   :; source .env.local && dapp --use solc:0.5.16 flat
clean  :; dapp clean
test   :; dapp test

salt   :; @create3 -s 00000000000000
deploy :; @bash ./bin/deploy.sh $(chain)

.PHONY: all flat clean test salt deploy
