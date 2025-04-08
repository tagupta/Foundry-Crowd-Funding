// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {FundMeScript} from "../script/FundMe.s.sol";
/**
 * @title Writing test cases for Fund Me contract
 */

contract FundMeTest is Test {
    // error FundMe__InsufficientFunds();
    FundMe fundMe;
    uint256 amountFromFundeMe;
    address USER = makeAddr("alice");
    uint256 constant SEND_VALUE = 5e18;
    uint256 constant STARTING_BALANCE = 1e18;

    function setUp() public {
        FundMeScript script = new FundMeScript();
        fundMe = script.run();
        vm.deal(address(fundMe), 0);
        vm.deal(fundMe.getOwner(), 0);
    }

    function test_FundMeOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
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
        uint256 amount = STARTING_BALANCE;
        uint256 amountAdded = address(fundMe).balance;
        // vm.deal(address(this), amount);
        fundMe.addFunds{value: amount}();
        assertEq(address(fundMe).balance, amountAdded + 1 ether);
    }

    function testCreditorAmountAdded() public {
        //Arrange
        uint256 amount = STARTING_BALANCE;
        uint256 amountAddedByCreditor = fundMe.getCreditorsFundedAmount(USER);
        // vm.prank(USER);
        // vm.deal(USER, amount);
        hoax(USER, amount);

        //Act
        fundMe.addFunds{value: amount}();

        //Assert
        assertEq(amountAddedByCreditor, 0);
        amountAddedByCreditor = fundMe.getCreditorsFundedAmount(USER);
        assertEq(STARTING_BALANCE, amountAddedByCreditor);
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
        vm.prank(USER);
        vm.expectRevert(FundMe.FundMe__UnauthorizedError.selector);
        fundMe.withdrawFunds();
    }

    function test_RevertWhenWithdrawnBeforeFundsRaised() public {
        vm.prank(fundMe.getOwner());
        vm.expectRevert(FundMe.FundMe__GoalNotCompletedYet.selector);
        fundMe.withdrawFunds();
    }

    modifier funded() {
        // vm.prank(USER);
        // vm.deal(USER, SEND_VALUE);
        hoax(USER, SEND_VALUE);
        fundMe.addFunds{value: SEND_VALUE}();
        _;
    }

    function test_RevertWhenMoreAddedThanNeeded() public funded {
        assertEq(address(fundMe).balance, SEND_VALUE);
        vm.deal(address(this), STARTING_BALANCE);
        vm.expectRevert(FundMe.FundMe__GoalCompleted.selector);
        fundMe.addFunds{value: STARTING_BALANCE}();
    }

    receive() external payable {
        console.log("Amount withdrawn from the fund me account to this account");
        amountFromFundeMe = msg.value;
    }

    function test_WhenCallerIsAContractWithReceiveEther() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.withdrawFunds();
        assertEq(address(fundMe).balance, 0);
    }

    modifier multipleFundsAdded(){
        uint256 noOfFunders = 5;
            for (uint160 i = 0; i < noOfFunders; i++) {
                hoax(address(i + 1), STARTING_BALANCE);
                fundMe.addFunds{value: STARTING_BALANCE}();
        }
        _;
    }

    function test_WhenMultipleFundersAddMoney() public multipleFundsAdded{
        uint256 sumAddedByCreditors;
        for (uint160 i; i < 5; i++) {
            sumAddedByCreditors += fundMe.getCreditorsFundedAmount(address(i + 1));
        }
        assertEq(address(fundMe).balance, sumAddedByCreditors);
        
    }

    function test_WithdrawWhen_MultipleFundsAdded() public multipleFundsAdded {
        vm.prank(fundMe.getOwner());
        fundMe.withdrawFunds();
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, SEND_VALUE);
    }
}
