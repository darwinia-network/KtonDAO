// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Checkpoints} from "@openzeppelin/contracts/utils/structs/Checkpoints.sol";
import "@flexible-voting/FlexVotingClient.sol";
import "./StakingRewards.sol";

contract StakingFlexVoting is StakingRewards, FlexVotingClient {
    using SafeCast for uint256;
    using Checkpoints for Checkpoints.Trace224;

    constructor(address _rewardsDistribution, address _token, address _governor)
        StakingRewards(_rewardsDistribution, _token)
        FlexVotingClient(_governor)
    {
        _selfDelegate();
    }

    function _rawBalanceOf(address _user) internal view virtual override returns (uint224) {
        return SafeCast.toUint224(balanceOf(_user));
    }

    function _castVoteReasonString() internal pure override returns (string memory) {
        return "rolled-up vote from StakingFlexVoting token holders";
    }

    function _updateVotes(address account) internal virtual override {
        FlexVotingClient._checkpointRawBalanceOf(account);
        FlexVotingClient.totalBalanceCheckpoints.push(
            SafeCast.toUint32(block.number), SafeCast.toUint224(totalSupply())
        );
    }
}
