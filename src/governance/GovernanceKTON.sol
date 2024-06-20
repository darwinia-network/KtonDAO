// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

contract GovernanceKton is ERC20, ERC20Permit, ERC20Votes, ERC20Wrapper {
    IERC20 public constant KTON = IERC20(0x0000000000000000000000000000000000000402);

    constructor() ERC20("Governance KTON", "gKTON") ERC20Permit("Governance KTON") ERC20Wrapper(KTON) {}

    function decimals() public view override(ERC20, ERC20Wrapper) returns (uint8) {
        return super.decimals();
    }

    // function clock() public view override returns (uint48) {
    //     return uint48(block.timestamp);
    // }
    //
    // function CLOCK_MODE() public pure override returns (string memory) {
    //     return "mode=timestamp";
    // }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
