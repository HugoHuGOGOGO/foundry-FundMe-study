//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

struct NetworkConfig {
    address priceFeed;
}

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant decimals = 8;
    int256 public constant initialAnswer = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return SepoliaConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator(
            decimals,
            initialAnswer
        );
        vm.stopBroadcast();
        NetworkConfig memory AnvilConfig = NetworkConfig({
            priceFeed: address(priceFeed)
        });
        return AnvilConfig;
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory MainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return MainnetConfig;
    }
}
