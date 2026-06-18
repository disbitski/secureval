// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {TokenPool} from "@chainlink/contracts-ccip/contracts/pools/TokenPool.sol";
import {RateLimiter} from "@chainlink/contracts-ccip/contracts/libraries/RateLimiter.sol";
import {NetworkConfig} from "./NetworkConfig.sol";

contract ConfigurePool is Script {
  function run() external {
    NetworkConfig.ChainConfig memory config = NetworkConfig.active();
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address localPool = vm.envAddress("LOCAL_POOL_ADDRESS");
    address remotePool = vm.envAddress("REMOTE_POOL_ADDRESS");
    address remoteToken = vm.envAddress("REMOTE_TOKEN_ADDRESS");
    uint64 remoteSelector = _envOrDefaultSelector("REMOTE_CHAIN_SELECTOR");

    TokenPool.ChainUpdate[] memory chains = new TokenPool.ChainUpdate[](1);
    bytes[] memory remotePools = new bytes[](1);
    remotePools[0] = abi.encode(remotePool);

    chains[0] = TokenPool.ChainUpdate({
      remoteChainSelector: remoteSelector,
      remotePoolAddresses: remotePools,
      remoteTokenAddress: abi.encode(remoteToken),
      outboundRateLimiterConfig: _rateLimiter("OUTBOUND"),
      inboundRateLimiterConfig: _rateLimiter("INBOUND")
    });

    uint64[] memory removals = new uint64[](0);

    vm.startBroadcast(deployerKey);
    TokenPool(localPool).applyChainUpdates(removals, chains);
    vm.stopBroadcast();

    console2.log("Network:", config.name);
    console2.log("Local pool configured:", localPool);
    console2.log("Remote chain selector:", remoteSelector);
    console2.log("Remote pool:", remotePool);
    console2.log("Remote token:", remoteToken);
  }

  function _rateLimiter(
    string memory prefix
  ) internal view returns (RateLimiter.Config memory) {
    bool enabled = vm.envBool(string.concat(prefix, "_RATE_LIMIT_ENABLED"));
    uint128 capacity = uint128(vm.envUint(string.concat(prefix, "_RATE_LIMIT_CAPACITY")));
    uint128 rate = uint128(vm.envUint(string.concat(prefix, "_RATE_LIMIT_RATE")));
    return RateLimiter.Config({isEnabled: enabled, capacity: capacity, rate: rate});
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
