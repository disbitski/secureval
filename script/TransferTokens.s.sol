// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts@4.8.3/token/ERC20/IERC20.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract TransferTokens is Script {
  function run() external returns (bytes32 messageId) {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    uint64 destinationSelector = _envOrDefaultSelector("DESTINATION_CHAIN_SELECTOR");
    address token = vm.envAddress("TOKEN_ADDRESS");
    address receiver = vm.envAddress("RECEIVER");
    uint256 amount = vm.envUint("AMOUNT");
    address feeToken = _envOrZero("FEE_TOKEN");

    Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
    tokenAmounts[0] = Client.EVMTokenAmount({token: token, amount: amount});

    Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
      receiver: abi.encode(receiver),
      data: "",
      tokenAmounts: tokenAmounts,
      feeToken: feeToken,
      extraArgs: Client._argsToBytes(Client.GenericExtraArgsV2({gasLimit: 0, allowOutOfOrderExecution: true}))
    });

    IRouterClient router = IRouterClient(config.router);
    uint256 fee = router.getFee(destinationSelector, message);

    vm.startBroadcast(deployerKey);
    IERC20(token).approve(config.router, amount);
    if (feeToken == address(0)) {
      messageId = router.ccipSend{value: fee}(destinationSelector, message);
    } else {
      IERC20(feeToken).approve(config.router, fee);
      messageId = router.ccipSend(destinationSelector, message);
    }
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Destination chain selector:", destinationSelector);
    console2.log("CCIP fee:", fee);
    console2.log("CCIP message ID:");
    console2.log(vm.toString(messageId));
    console2.log("CCIP Explorer:");
    console2.log(string.concat("https://ccip.chain.link/msg/", vm.toString(messageId)));
  }

  function _envOrZero(
    string memory key
  ) internal view returns (address) {
    try vm.envAddress(key) returns (address value) {
      return value;
    } catch {
      return address(0);
    }
  }

  function _envOrDefaultSelector(
    string memory key
  ) internal view returns (uint64) {
    try vm.envUint(key) returns (uint256 selector) {
      require(selector <= type(uint64).max, "selector too large");
      // forge-lint: disable-next-line(unsafe-typecast)
      return uint64(selector);
    } catch {
      return NetworkConfig.remoteSelector();
    }
  }
}
