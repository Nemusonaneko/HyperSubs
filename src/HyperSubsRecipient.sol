// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "solady/utils/SafeTransferLib.sol";

interface ILiquidityLayerMessageRecipient {
    function handleWithTokens(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message,
        address _token,
        uint256 _amount
    ) external;
}

interface IHyperSubs {
    function createSubscription(address _recipient, uint256 _months) external;

    function extendSubscription(uint256 _id, uint256 _months) external;
}

contract HyperSubsRecipient is ILiquidityLayerMessageRecipient {
    event ReceivedMessage(
        uint32 indexed origin,
        bytes32 indexed sender,
        bytes data,
        address token,
        uint256 amount
    );

    function handleWithTokens(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message,
        address _token,
        uint256 _amount
    ) external {
        (
            address subContract,
            address destinationToken,
            bool newSub,
            uint256 monthsToSub,
            uint256 tokenId,
            address recipientOfSub
        ) = abi.decode(
                _message,
                (address, address, bool, uint256, uint256, address)
            );

        SafeTransferLib.safeApprove(destinationToken, subContract, _amount);
        if (newSub) {
            IHyperSubs(subContract).createSubscription(
                recipientOfSub,
                monthsToSub
            );
        } else {
            IHyperSubs(subContract).extendSubscription(tokenId, monthsToSub);
        }
        emit ReceivedMessage(_origin, _sender, _message, _token, _amount);
    }
}
