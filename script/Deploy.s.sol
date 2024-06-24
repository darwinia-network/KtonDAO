// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {safeconsole} from "forge-std/safeconsole.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

import {GovernanceKton} from "../src/governance/GovernanceKton.sol";
import {KtonDAO, IVotes, TimelockControllerUpgradeable} from "../src/governance/KtonDAO.sol";
import {KtonTimelockController} from "../src/governance/KtonTimelockController.sol";
import {KtonDAOVault} from "../src/staking/KtonDAOVault.sol";

contract DeployScript is Script {
    address gKTON = 0x01840055063E8d56C957b79C964D7fc50a825752;
    address ktonDAO = 0x34D4519c574047c9D7F9E79b2bc718aef159129B;
    address timelock = 0xCA435c493Ee55AB27e8C8b1b1a89706c5a2761b5;
    address vault = 0x0DBFbb1Ab6e42F89661B4f98d5d0acdBE21d1ffC;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address gKTON_PROXY = Upgrades.deployTransparentProxy(
            "GovernanceKton.sol:GovernanceKton", timelock, abi.encodeCall(GovernanceKton.initialize, (vault))
        );
        safeconsole.log("gKTON: ", gKTON_PROXY);
        safeconsole.log("gKTON_Logic: ", Upgrades.getImplementationAddress(gKTON_PROXY));

        address ktonDAO_PROXY = Upgrades.deployTransparentProxy(
            "KtonDAO.sol:KtonDAO",
            timelock,
            abi.encodeCall(
                KtonDAO.initialize,
                (IVotes(gKTON), TimelockControllerUpgradeable(payable(timelock)), 1 days, 30 days, 200e18, "KtonDAO")
            )
        );
        safeconsole.log("KtonDAO: ", ktonDAO_PROXY);
        safeconsole.log("KtonDAO_Logic: ", Upgrades.getImplementationAddress(ktonDAO_PROXY));

        uint256 minDelay = 3 days;
        address[] memory proposers = new address[](1);
        proposers[0] = ktonDAO;
        KtonTimelockController timelockController =
            new KtonTimelockController(minDelay, proposers, new address[](0), address(0));
        safeconsole.log("Timelock: ", address(timelockController));

        address KtonDAOVault_PROXY = Upgrades.deployTransparentProxy(
            "KtonDAOVault.sol:KtonDAOVault", timelock, abi.encodeCall(KtonDAOVault.initialize, (timelock, gKTON))
        );
        safeconsole.log("KtonDAOVault: ", KtonDAOVault_PROXY);
        safeconsole.log("KtonDAOVault_Logic: ", Upgrades.getImplementationAddress(KtonDAOVault_PROXY));

        vm.stopBroadcast();
    }
}
