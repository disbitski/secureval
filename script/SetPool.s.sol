// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ITokenAdminRegistry} from "@chainlink/contracts-ccip/contracts/interfaces/ITokenAdminRegistry.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract SetPool is Script {
  function run() external {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address token = vm.envAddress("TOKEN_ADDRESS");
    address pool = vm.envAddress("POOL_ADDRESS");

    vm.startBroadcast(deployerKey);
    ITokenAdminRegistry(config.tokenAdminRegistry).setPool(token, pool);
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Token:", token);
    console2.log("Pool set:", pool);
  }
}
