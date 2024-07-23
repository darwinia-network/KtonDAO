// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {safeconsole} from "forge-std/safeconsole.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

import {GovernanceKTON} from "../src/governance/GovernanceKTON.sol";
import {KtonDAO, IVotes, TimelockControllerUpgradeable} from "../src/governance/KtonDAO.sol";
import {KtonTimelockController} from "../src/governance/KtonTimelockController.sol";
import {KtonDAOVault} from "../src/staking/KtonDAOVault.sol";

contract DeployScript is Script {
    address gKTON = 0x6FB1cE2dc2043FEc15d4d8A58cAF06a47A8f025F;
    address ktonDAO = 0xfe024E36B116bBFCb337BfD71a8C9e32330dA128;
    address timelock = 0x80dEE0851313a46b2a8604209B1f3225E1721c9a;
    address vault = 0xf1b4f3D438eE2B363C5ba1641A498709ff5780bA;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address gKTON_PROXY = Upgrades.deployTransparentProxy(
            "GovernanceKTON.sol:GovernanceKTON", timelock, abi.encodeCall(GovernanceKTON.initialize, (vault))
        );
        safeconsole.log("gKTON: ", gKTON_PROXY);
        safeconsole.log("gKTON_Logic: ", Upgrades.getImplementationAddress(gKTON_PROXY));

        Options memory opts;
        uint256 quorum = 3_000e18;
        opts.constructorData = abi.encode(quorum);
        address ktonDAO_PROXY = Upgrades.deployTransparentProxy(
            "KtonDAO.sol:KtonDAO",
            timelock,
            abi.encodeCall(
                KtonDAO.initialize,
                (IVotes(gKTON), TimelockControllerUpgradeable(payable(timelock)), 1 days, 30 days, 20e18, "KtonDAO")
            ),
            opts
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
