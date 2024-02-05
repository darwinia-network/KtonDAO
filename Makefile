all    :; source .env.local && dapp --use solc:0.5.16 build
flat   :; source .env.local && dapp --use solc:0.5.16 flat
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create Staker

.PHONY: all flat clean test
