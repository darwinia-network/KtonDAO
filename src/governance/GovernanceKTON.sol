// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../staking/StakingRewards.sol";

contract GovernanceKton is ERC20Upgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, StakingRewards {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _rewardsDistribution) public initializer {
        __StakingRewards_init(_rewardsDistribution);
        __ERC20_init("Governance KTON", "gKTON");
        __ERC20Permit_init("Governance KTON");
        __ERC20Votes_init();
    }

    function _issue(address account, uint256 value) internal override {
        _mint(account, value);
    }

    function _destroy(address account, uint256 value) internal override {
        _burn(account, value);
    }

    function _delegateTo(address account, address delegatee) internal override {
        _delegate(account, delegatee);
    }

    function transfer(address, uint256) public override returns (bool) {
        revert();
    }

    function transferFrom(address, address, uint256) public override returns (bool) {
        revert();
    }

    function approve(address, uint256) public override returns (bool) {
        revert();
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20PermitUpgradeable, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }
}
