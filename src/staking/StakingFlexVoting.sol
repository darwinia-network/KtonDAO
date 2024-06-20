// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@flexible-voting/FlexVotingClient.sol";
import "./KTONStakingRewards.sol";

contract StakingFlexVoting is KTONStakingRewards, FlexVotingClient {
    constructor(address _rewardsDistribution, address _governor)
        KTONStakingRewards(_token)
        FlexVotingClient(_governor)
    {
        _selfDelegate();
    }

    function _rawBalanceOf(address _user) internal view virtual override returns (uint256) {
        return _balances[_user];
    }

    function _castVoteReasonString() internal override returns (string memory) {
        return "rolled-up vote from StakingFlexVoting token holders";
    }

    function _updateVotes(address account) internal virtual override {
        FlexVotingClient._checkpointRawBalanceOf(account);
        FlexVotingClient.totalBalanceCheckpoints.push(_totalSupply);
    }
}
