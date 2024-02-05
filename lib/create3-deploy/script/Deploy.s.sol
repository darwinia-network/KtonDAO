// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";

import {Common} from "./Common.s.sol";
import {CREATE3Factory} from "../src/CREATE3Factory.sol";

contract Deploy is Common {
    using stdJson for string;

    address immutable ADDR = 0x0000000000C76fe1798a428F60b27c6724e03408;
    bytes32 immutable SALT = 0xbdfe2ef43e1e3ce6492866175ab332d54a06ed033ec746975e32aa0c45dbbce0;

    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();
    }

    function run() public {
        deploy();
    }

    function deploy() public broadcast returns (address) {
        bytes memory initCode = type(CREATE3Factory).creationCode;
        address factory = _deploy2(SALT, initCode);
        require(factory == ADDR, "!addr");
        return factory;
    }
}
