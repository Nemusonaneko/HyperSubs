// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "solady/auth/Ownable.sol";
import "solady/utils/SafeTransferLib.sol";

interface ILiquidityLayerRouter {
    function dispatchWithTokens(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        address _token,
        uint256 _amount,
        string calldata _bridge,
        bytes calldata _messageBody
    ) external returns (bytes32);
}

interface IInterchainGasPaymaster {
    function payForGas(
        bytes32 _messageId,
        uint32 _destinationDomain,
        uint256 _gasAmount,
        address _refundAddress
    ) external payable;

    function quoteGasPayment(
        uint32 _destinationDomain,
        uint256 _gasAmount
    ) external view returns (uint256);
}

contract HyperSubsRouter is Ownable {
    ILiquidityLayerRouter public liquidityLayerRouter;
    IInterchainGasPaymaster public interchainGasPaymaster;
    uint256 public gasAmount;

    constructor(
        address _liquidityLayerRouter,
        address _interchainGasPaymaster,
        uint256 _gasAmount
    ) {
        _initializeOwner(msg.sender);
        liquidityLayerRouter = ILiquidityLayerRouter(_liquidityLayerRouter);
        interchainGasPaymaster = IInterchainGasPaymaster(
            _interchainGasPaymaster
        );
        gasAmount = _gasAmount;
    }

    function changeParams(
        address _liquidityLayerRouter,
        address _interchainGasPaymaster,
        uint256 _gasAmount
    ) external onlyOwner {
        liquidityLayerRouter = ILiquidityLayerRouter(_liquidityLayerRouter);
        interchainGasPaymaster = IInterchainGasPaymaster(
            _interchainGasPaymaster
        );
        gasAmount = _gasAmount;
    }

    function createNewSubMessage(
        uint32 _destinationChain,
        address _destinationReceiver,
        address _tokenToTransfer,
        uint256 _amountToTransfer,
        string calldata _bridgeToUse,
        address _subContract,
        address _destinationToken,
        uint256 _monthsToSub,
        address _recipientOfSub
    ) external payable {
        bytes memory message = bytes(
            abi.encode(
                _subContract,
                _destinationToken,
                true,
                _monthsToSub,
                0,
                _recipientOfSub
            )
        );
        SafeTransferLib.safeTransferFrom(
            _tokenToTransfer,
            msg.sender,
            address(this),
            _amountToTransfer
        );
        SafeTransferLib.safeApprove(
            _tokenToTransfer,
            address(liquidityLayerRouter),
            _amountToTransfer
        );
        bytes32 messageId = liquidityLayerRouter.dispatchWithTokens(
            _destinationChain,
            addressToBytes32(_destinationReceiver),
            _tokenToTransfer,
            _amountToTransfer,
            _bridgeToUse,
            message
        );
        interchainGasPaymaster.payForGas{value: msg.value}(
            messageId,
            _destinationChain,
            gasAmount,
            msg.sender
        );
    }

    function extendSubMessage(
        uint32 _destinationChain,
        address _destinationReceiver,
        address _tokenToTransfer,
        uint256 _amountToTransfer,
        string calldata _bridgeToUse,
        address _subContract,
        address _destinationToken,
        uint256 _monthsToSub,
        uint256 _tokenId
    ) external payable {
        bytes memory message = bytes(
            abi.encode(
                _subContract,
                _destinationToken,
                false,
                _monthsToSub,
                _tokenId,
                address(0)
            )
        );
        SafeTransferLib.safeTransferFrom(
            _tokenToTransfer,
            msg.sender,
            address(this),
            _amountToTransfer
        );
        SafeTransferLib.safeApprove(
            _tokenToTransfer,
            address(liquidityLayerRouter),
            _amountToTransfer
        );
        bytes32 messageId = liquidityLayerRouter.dispatchWithTokens(
            _destinationChain,
            addressToBytes32(_destinationReceiver),
            _tokenToTransfer,
            _amountToTransfer,
            _bridgeToUse,
            message
        );
        interchainGasPaymaster.payForGas{value: msg.value}(
            messageId,
            _destinationChain,
            gasAmount,
            msg.sender
        );
    }

    function addressToBytes32(address _address) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_address)));
    }
}
