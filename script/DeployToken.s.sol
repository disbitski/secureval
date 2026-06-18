// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {BurnMintERC20} from "@chainlink/contracts/src/v0.8/shared/token/ERC20/BurnMintERC20.sol";

contract DeployToken is Script {
  function run() external returns (BurnMintERC20 token) {
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    string memory name = vm.envString("TOKEN_NAME");
    string memory symbol = vm.envString("TOKEN_SYMBOL");
    uint8 decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
    uint256 maxSupply = vm.envUint("TOKEN_MAX_SUPPLY");
    uint256 preMint = vm.envUint("TOKEN_PREMINT");

    vm.startBroadcast(deployerKey);
    token = new BurnMintERC20(name, symbol, decimals, maxSupply, preMint);
    token.grantMintAndBurnRoles(vm.addr(deployerKey));
    vm.stopBroadcast();

    console2.log("BurnMintERC20 deployed:", address(token));
    console2.log("Token admin:", vm.addr(deployerKey));
  }
}
