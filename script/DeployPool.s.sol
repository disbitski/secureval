// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {BurnMintERC20} from "@chainlink/contracts/src/v0.8/shared/token/ERC20/BurnMintERC20.sol";
import {IBurnMintERC20} from "@chainlink/contracts/src/v0.8/shared/token/ERC20/IBurnMintERC20.sol";
import {BurnMintTokenPool} from "@chainlink/contracts-ccip/contracts/pools/BurnMintTokenPool.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract DeployPool is Script {
  function run() external returns (BurnMintTokenPool pool) {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    BurnMintERC20 token = BurnMintERC20(vm.envAddress("TOKEN_ADDRESS"));
    address[] memory allowlist = new address[](0);

    vm.startBroadcast(deployerKey);
    pool = new BurnMintTokenPool(IBurnMintERC20(address(token)), token.decimals(), allowlist, config.rmnProxy, config.router);
    token.grantMintAndBurnRoles(address(pool));
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("BurnMintTokenPool deployed:", address(pool));
    console2.log("Token:", address(token));
  }
}
