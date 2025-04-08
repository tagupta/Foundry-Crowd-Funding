/**
 * 1. Deploy mocks when you are on a local anvil chain
 * 2. Keep track of contract addresses across different chains
 * - Sepolia ETH/USD
 * - Mainnet ETH/USD
 */
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public networkActiveConfig;
    
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    uint public constant SEPOLIA_ETH_CHAINID = 11155111;
    uint public constant MAINNET_ETH_CHAINID = 1;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed
    }

    constructor() {
        if (block.chainid == SEPOLIA_ETH_CHAINID) {
            networkActiveConfig = getSepoliaEthConfig();
        } else if (block.chainid == MAINNET_ETH_CHAINID) {
            networkActiveConfig = getEthConfig();
        } else {
            networkActiveConfig = getorCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaConfig;
    }

    function getEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return ethConfig;
    }

    function getorCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(networkActiveConfig.priceFeed != address(0)){
            console.log("Called up heer");
            return networkActiveConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator aggregatorInterace = new MockV3Aggregator({
            _decimals: DECIMALS, 
            _initialAnswer: INITIAL_PRICE
        });
        //Deploy the mock contract
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig(address(aggregatorInterace));
        return anvilConfig;
    }
}
