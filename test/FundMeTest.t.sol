// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {FundMeScript} from "../script/FundMe.s.sol";
/**
 * @title Writing test cases for Fund Me contract
 * @author Writer
 */

contract FundMeTest is Test {
    // error FundMe__InsufficientFunds();
    FundMe fundMe;
    uint256 amountFromFundeMe;

    function setUp() public {
        FundMeScript script = new FundMeScript();
        fundMe = script.run();
        vm.deal(address(fundMe), 0);
    }

    function test_FundMeOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_FundsNotAddedYet() public view {
        uint256 amountNeeded = fundMe.getNeededAmount();
        uint256 amountAdded = address(fundMe).balance;
        assertTrue(amountNeeded > amountAdded);
    }

    function test_AmountAddedIs0() public view {
        uint256 amountAdded = address(fundMe).balance;
        assertEq(amountAdded, 0);
    }

    function test__SendAmount() public {
        uint256 amount = 1e18;
        uint256 amountAdded = address(fundMe).balance;
        // vm.deal(address(this), amount);
        fundMe.addFunds{value: amount}();
        assertEq(address(fundMe).balance, amountAdded + 1 ether);
    }

    function test_RevertWithVeryHighAmountAdded() public {
        uint256 amount = type(uint256).max;
        vm.deal(address(this), amount);
        vm.expectRevert(stdError.arithmeticError);
        fundMe.addFunds{value: amount}();
    }

    function test_RevertWhenInsufficientAmountAdded() public {
        uint256 amount = 0.002 ether;
        vm.deal(address(this), amount);
        vm.expectRevert(FundMe.FundMe__InsufficientFunds.selector);
        fundMe.addFunds{value: amount}();
    }

    function test_RevertWhenNonOwnerWithdraws() public {
        vm.prank(address(0x123));
        vm.expectRevert(FundMe.FundMe__UnauthorizedError.selector);
        fundMe.withdrawFunds();
    }

    function test_RevertWhenWithdrawnBeforeFundsRaised() public {
        vm.prank(msg.sender);
        vm.expectRevert(FundMe.FundMe__GoalNotCompletedYet.selector);
        fundMe.withdrawFunds();
    }

    function test_RevertWhenMoreAddedThanNeeded() public {
        uint256 amount = 5e18;
        vm.prank(address(0x232));
        vm.deal(address(0x232), amount);
        fundMe.addFunds{value: amount}();
        assertEq(address(fundMe).balance, amount);
        amount = 1e18;
        vm.deal(address(this), amount);
        vm.expectRevert(FundMe.FundMe__GoalCompleted.selector);
        fundMe.addFunds{value: amount}();
    }

    receive() external payable {
        console.log("Amount withdrawn from the fund me account to this account");
        amountFromFundeMe = msg.value;
    }

    function test_WhenCallerIsAContractWithReceiveEther() public {
        uint256 amount = 5e18;
        vm.prank(address(0x232));
        vm.deal(address(0x232), amount);
        fundMe.addFunds{value: amount}();
        vm.prank(msg.sender);
        fundMe.withdrawFunds();
        assertEq(address(fundMe).balance, 0);
    }

    // function test_PriceFeedVersionIsAccurate4() public view {
    //     uint256 version = fundMe.getVersion();
    //     assertEq(version, 4);
    // }
}
