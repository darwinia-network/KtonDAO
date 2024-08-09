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
    address gKTON = 0xa42980efF5439F97A768F0B7a00c70ff0a213977;
    address ktonDAO = 0xF3522CA27807ED1264e399FaC42e8621Db4b5Dc4;
    address timelock = 0xb80b7Bd1001d6B5D4a9bf0d3524b85b244147C30;
    address vault = 0x9e5cED4C978F92591fD0609c5c781e6aDdB75ac0;

    struct Settings {
        uint256 quorum;
        uint256 initialProposalThreshold;
        uint32 initialVotingPeriod;
        uint256 timelockDeplay;
    }

    function getSettings(uint256 chainId) public pure returns (Settings memory) {
        if (chainId == 701) {
            return Settings({
                quorum: 3e16,
                initialProposalThreshold: 1e16,
                initialVotingPeriod: 1 hours,
                timelockDeplay: 0
            });
        } else if (chainId == 44) {
            return Settings({
                quorum: 4_500e18,
                initialProposalThreshold: 35e18,
                initialVotingPeriod: 30 days,
                timelockDeplay: 3 days
            });
        } else if (chainId == 46) {
            return Settings({
                quorum: 3_000e18,
                initialProposalThreshold: 20e18,
                initialVotingPeriod: 30 days,
                timelockDeplay: 3 days
            });
        }
    }

    function run() public {
        vm.startBroadcast();

        safeconsole.log("Chain Id: ", block.chainid);
        Settings memory s = getSettings(block.chainid);

        address gKTON_PROXY = Upgrades.deployTransparentProxy(
            "GovernanceKTON.sol:GovernanceKTON", timelock, abi.encodeCall(GovernanceKTON.initialize, (vault))
        );
        safeconsole.log("gKTON: ", gKTON_PROXY);
        safeconsole.log("gKTON_Logic: ", Upgrades.getImplementationAddress(gKTON_PROXY));

        Options memory opts;
        uint256 quorum = s.quorum;
        opts.constructorData = abi.encode(quorum);
        address ktonDAO_PROXY = Upgrades.deployTransparentProxy(
            "KtonDAO.sol:KtonDAO",
            timelock,
            abi.encodeCall(
                KtonDAO.initialize,
                (
                    IVotes(gKTON),
                    TimelockControllerUpgradeable(payable(timelock)),
                    0,
                    s.initialVotingPeriod,
                    s.initialProposalThreshold,
                    "KtonDAO"
                )
            ),
            opts
        );
        safeconsole.log("KtonDAO: ", ktonDAO_PROXY);
        safeconsole.log("KtonDAO_Logic: ", Upgrades.getImplementationAddress(ktonDAO_PROXY));

        uint256 minDelay = s.timelockDeplay;
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
