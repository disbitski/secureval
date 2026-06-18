// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library NetworkConfig {
  uint256 internal constant ETHEREUM_SEPOLIA_CHAIN_ID = 11155111;
  uint256 internal constant AVALANCHE_FUJI_CHAIN_ID = 43113;

  uint64 internal constant ETHEREUM_SEPOLIA_SELECTOR = 16015286601757825753;
  uint64 internal constant AVALANCHE_FUJI_SELECTOR = 14767482510784806043;

  struct ChainConfig {
    string name;
    uint64 chainSelector;
    address router;
    address rmnProxy;
    address tokenAdminRegistry;
    address registryModuleOwnerCustom;
    address linkToken;
  }

  function active() internal view returns (ChainConfig memory config) {
    if (block.chainid == ETHEREUM_SEPOLIA_CHAIN_ID) {
      return ethereumSepolia();
    }
    if (block.chainid == AVALANCHE_FUJI_CHAIN_ID) {
      return avalancheFuji();
    }
    revert("unsupported chain");
  }

  function remoteSelector() internal view returns (uint64 selector) {
    if (block.chainid == ETHEREUM_SEPOLIA_CHAIN_ID) {
      return AVALANCHE_FUJI_SELECTOR;
    }
    if (block.chainid == AVALANCHE_FUJI_CHAIN_ID) {
      return ETHEREUM_SEPOLIA_SELECTOR;
    }
    revert("unsupported chain");
  }

  function ethereumSepolia() internal pure returns (ChainConfig memory config) {
    return ChainConfig({
      name: "Ethereum Sepolia",
      chainSelector: ETHEREUM_SEPOLIA_SELECTOR,
      router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
      rmnProxy: 0xba3f6251de62dED61Ff98590cB2fDf6871FbB991,
      tokenAdminRegistry: 0x95F29FEE11c5C55d26cCcf1DB6772DE953B37B82,
      registryModuleOwnerCustom: 0xa3c796d480638d7476792230da1E2ADa86e031b0,
      linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
    });
  }

  function avalancheFuji() internal pure returns (ChainConfig memory config) {
    return ChainConfig({
      name: "Avalanche Fuji",
      chainSelector: AVALANCHE_FUJI_SELECTOR,
      router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
      rmnProxy: 0xAc8CFc3762a979628334a0E4C1026244498E821b,
      tokenAdminRegistry: 0xA92053a4a3922084d992fD2835bdBa4caC6877e6,
      registryModuleOwnerCustom: 0xefa93f3312840683893DbdeB3d53359b2d948F50,
      linkToken: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
    });
  }
}
