// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
import {Counter} from "../src/KTONStakingRewards.sol";

contract Deploy is Common {
    address immutable ADDR = 0x00C4B0e8c35a42EfA8ECb67b2155a9A573A632E7;
    bytes32 immutable SALT = 0x3830f8dca3fab67fa3cf818f45f5dd870f59f600635be259e1ba3081237ef146;

    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();
    }

    function run() public broadcast {
        bytes memory byteCode = type(KTONStakingRewards).creationCode;
        address addr = _deploy3(SALT, byteCode);
        require(addr == ADDR, "!addr");
    }
}
