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
    address gKTON = 0xB633Ad1142941CA2Eb9C350579cF88BbE266660D;
    address ktonDAO = 0xaAC63c40930cCAF99603229F6381D82966b145ef;
    address timelock = 0x08837De0Ae21C270383D9F2de4DB03c7b1314632;
    address vault = 0x652182C6aBc0bBE41b5702b05a26d109A405EAcA;

    struct Settings {
        string gKtonName;
        string gKtonSymbol;
        string daoName;
        uint256 quorum;
        uint256 initialProposalThreshold;
        uint32 initialVotingPeriod;
        uint256 timelockDeplay;
    }

    function getSettings(uint256 chainId) public pure returns (Settings memory) {
        if (chainId == 701) {
            return Settings({
                gKtonName: "Governance PKTON",
                gKtonSymbol: "gPKTON",
                daoName: "PKtonDAO",
                quorum: 3e16,
                initialProposalThreshold: 1e16,
                initialVotingPeriod: 1 hours,
                timelockDeplay: 0
            });
        } else if (chainId == 44) {
            return Settings({
                gKtonName: "Governance CKTON",
                gKtonSymbol: "gCKTON",
                daoName: "CKtonDAO",
                quorum: 4_500e18,
                initialProposalThreshold: 35e18,
                initialVotingPeriod: 30 days,
                timelockDeplay: 3 days
            });
        } else if (chainId == 46) {
            return Settings({
                gKtonName: "Governance KTON",
                gKtonSymbol: "gKTON",
                daoName: "KtonDAO",
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
            "GovernanceKTON.sol:GovernanceKTON",
            timelock,
            abi.encodeCall(GovernanceKTON.initialize, (vault, s.gKtonName, s.gKtonSymbol))
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
                    s.daoName
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
