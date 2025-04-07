// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {FundMe} from '../src/FundMe.sol';

contract FundMeScript is Script{
    
    function run() external {
        vm.startBroadcast();
        //using the sepolia network address to get the value of ETH/USD
        new FundMe("tanu", 5e18, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
    }
}