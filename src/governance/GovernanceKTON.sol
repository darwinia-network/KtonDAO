// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "../staking/StakingRewards.sol";

contract GovernanceKTON is
    ERC165Upgradeable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    StakingRewards
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _rewardsDistribution) public initializer {
        __StakingRewards_init(_rewardsDistribution);
        __ERC20_init("Governance KTON", "gKTON");
        __ERC20Permit_init("Governance KTON");
        __ERC20Votes_init();
        __ERC165_init();
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(IERC20).interfaceId || _interfaceId == type(IERC20Permit).interfaceId
            || _interfaceId == type(IERC20Metadata).interfaceId || _interfaceId == type(IVotes).interfaceId
            || super.supportsInterface(_interfaceId);
    }

    function lockAndStake(uint256 amount) external override {
        _stake(amount);
        _mint(msg.sender, amount);
    }

    function unlockAndWithdraw(uint256 amount) external override {
        _withdraw(amount);
        _burn(msg.sender, amount);
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
