// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryModuleOwnerCustom} from "@chainlink/contracts-ccip/contracts/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract ClaimAdmin is Script {
  function run() external {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address token = vm.envAddress("TOKEN_ADDRESS");

    vm.startBroadcast(deployerKey);
    RegistryModuleOwnerCustom(config.registryModuleOwnerCustom).registerAdminViaGetCCIPAdmin(token);
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Pending admin claimed for token:", token);
  }
}
