// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {BurnMintERC20} from "@chainlink/contracts/src/v0.8/shared/token/ERC20/BurnMintERC20.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract Mint is Script {
  function run() external {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    BurnMintERC20 token = BurnMintERC20(vm.envAddress("TOKEN_ADDRESS"));
    address receiver = vm.envAddress("RECEIVER");
    uint256 amount = vm.envUint("AMOUNT");

    vm.startBroadcast(deployerKey);
    token.mint(receiver, amount);
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Minted token:", address(token));
    console2.log("Receiver:", receiver);
    console2.log("Amount:", amount);
  }
}
