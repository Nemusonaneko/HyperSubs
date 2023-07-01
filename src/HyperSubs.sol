// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/SafeTransferLib.sol";

contract HyperSubs is ERC721, Ownable {
    event SubscriptionCreated(
        uint256 id,
        address recipient,
        uint256 months,
        uint256 cost
    );

    event SubscriptionExtended(uint256 id, uint256 months, uint256 cost);

    uint256 public nextTokenId;
    uint256 public costPerMo;
    address public token;

    mapping(uint256 => uint256) public tokenIdToExpiration;

    constructor(address _token, uint256 _costPerMo) {
        _initializeOwner(msg.sender);
        token = _token;
        costPerMo = _costPerMo;
    }

    function name() public pure override returns (string memory) {
        return "HyperSubs";
    }

    function symbol() public pure override returns (string memory) {
        return "HSUB";
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (id >= nextTokenId) return "Lmeow";
        return "Milady";
    }

    function createSubscription(address _recipient, uint256 _months) external {
        uint256 cost = costPerMo * _months;
        uint256 id = nextTokenId;
        SafeTransferLib.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            cost
        );
        _safeMint(_recipient, nextTokenId);
        unchecked {
            tokenIdToExpiration[nextTokenId] =
                block.timestamp +
                (4 weeks * _months);
            ++nextTokenId;
        }
        emit SubscriptionCreated(id, _recipient, _months, cost);
    }

    function extendSubscription(uint256 _id, uint256 _months) external {
        require(tokenIdToExpiration[_id] > 0, "Subscription not active");
        uint256 cost = costPerMo * _months;
        SafeTransferLib.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            cost
        );
        unchecked {
            uint256 lastExpiry = tokenIdToExpiration[_id];
            if (block.timestamp >= lastExpiry) {
                tokenIdToExpiration[_id] =
                    block.timestamp +
                    (4 weeks * _months);
            } else {
                tokenIdToExpiration[_id] = lastExpiry + (4 weeks * _months);
            }
        }
        emit SubscriptionExtended(_id, _months, cost);
    }

    function retrieveFunds(address _token) external onlyOwner {
        SafeTransferLib.safeTransferAll(_token, msg.sender);
    }

    function changeParams(
        address _token,
        uint256 _costPerMo
    ) external onlyOwner {
        token = _token;
        costPerMo = _costPerMo;
    }
}
