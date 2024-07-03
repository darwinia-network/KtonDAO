// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract KtonTimelockController is TimelockController, AccessControlEnumerable {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin)
        TimelockController(minDelay, proposers, executors, admin)
    {}

    function _grantRole(bytes32 role, address account)
        internal
        override(AccessControl, AccessControlEnumerable)
        returns (bool)
    {
        return super._grantRole(role, account);
    }

    function _revokeRole(bytes32 role, address account)
        internal
        override(AccessControl, AccessControlEnumerable)
        returns (bool)
    {
        return super._revokeRole(role, account);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(TimelockController, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
