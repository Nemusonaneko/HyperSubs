// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/HyperSubsRouter.sol";

contract DeployRouter is Script {
    address public liquidityLayerRouter =
        0x2abe0860D81FB4242C748132bD69D125D88eaE26;
    address public interchainGasPaymaster =
        0xF90cB82a76492614D07B82a7658917f3aC811Ac1;
    /// Too lazy to input specifc gas amount so 1M is fine lmeow
    uint256 public gasAmount = 1000000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        HyperSubsRouter router = new HyperSubsRouter(
            liquidityLayerRouter,
            interchainGasPaymaster,
            gasAmount
        );
        vm.stopBroadcast();
    }
}
