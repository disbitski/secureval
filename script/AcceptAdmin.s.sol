// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ITokenAdminRegistry} from "@chainlink/contracts-ccip/contracts/interfaces/ITokenAdminRegistry.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract AcceptAdmin is Script {
  function run() external {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address token = vm.envAddress("TOKEN_ADDRESS");

    vm.startBroadcast(deployerKey);
    ITokenAdminRegistry(config.tokenAdminRegistry).acceptAdminRole(token);
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Admin accepted for token:", token);
  }
}
