// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/HyperSubsRecipient.sol";
import "../src/HyperSubs.sol";

contract DeployRecipientAndSubs is Script {
    /// USDC token
    address public token = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
    /// Price per month in USDC decimals
    uint256 public costPerMo = 1000000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        HyperSubsRecipient recipient = new HyperSubsRecipient();
        HyperSubs subs = new HyperSubs(token, costPerMo);
        vm.stopBroadcast();
    }
}
