// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant INITIAL_VALUE = 5e18;
    address USER = makeAddr("alice");

    function fundFundMe(address mostRecentDeployed) public payable {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).addFunds{value: INITIAL_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostDeployedFundMe);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdrawFunds();
        vm.stopBroadcast();
    }

    function run() external {
        address mostDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostDeployedFundMe);
        vm.stopBroadcast();
    }
}
