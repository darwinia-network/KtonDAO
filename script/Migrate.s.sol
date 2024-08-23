// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {safeconsole} from "forge-std/safeconsole.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Core} from "openzeppelin-foundry-upgrades/internal/Core.sol";

import {KtonDAOVault} from "../src/staking/KtonDAOVault.sol";

contract MigrateScript is Script {
    address vault = 0x652182C6aBc0bBE41b5702b05a26d109A405EAcA;
    address v2 = 0xC4784B3593fF0ace8773ec79EF4F8D8901a8DCfC;

    function run() public {
        vm.startBroadcast();

        Core.upgradeProxyTo(vault, v2, abi.encodeCall(KtonDAOVault.initializeV2, ()));

        vm.stopBroadcast();
    }
}
