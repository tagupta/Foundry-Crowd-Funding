// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address helperConfigAddress = helperConfig.networkActiveConfig();
        vm.startBroadcast();
        //using the sepolia network address to get the value of ETH/USD
        FundMe fundMe = new FundMe("tanu", 5e18, helperConfigAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
