// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;


import {FundMe} from '../src/FundMe.sol';
import  {Test, console} from 'forge-std/Test.sol';
import {stdError} from 'forge-std/StdError.sol';
/**
 * @title Writing test cases for Fund Me contract
 * @author Writer 
 */
contract FundMeTest is Test{
    // error FundMe__InsufficientFunds();
    FundMe fundMe;
    uint amountFromFundeMe;
    function setUp() public {
         fundMe = new FundMe("Alan", 3e18, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function test_FundMeOwner() public view{
        console.log("FundMe owner: ", fundMe.i_owner());
        assertEq(fundMe.i_owner(), address(this));
    }
    
    function test_AddFunds() public view{
        uint amountNeeded = fundMe.getNeededAmount();
        uint amountAdded = address(fundMe).balance;
        assertTrue(amountNeeded > amountAdded);
    }

    function test_AmountAddedIs0() public view{
        uint amountAdded = address(fundMe).balance;
        assertEq(amountAdded, 0);
    }

    function test__SendAmount() public{
        uint amount = 1e18;
        uint amountAdded = address(fundMe).balance;
        // vm.deal(address(this), amount);
        fundMe.addFunds{value: amount}();
        assertEq(address(fundMe).balance, amountAdded + 1 ether);
    }
    
    function test_RevertWithVeryHighAmountAdded() public {
        uint amount = type(uint).max;
        vm.deal(address(this), amount);
        vm.expectRevert(stdError.arithmeticError);
        fundMe.addFunds{value: amount}();
    }

    function test_RevertWhenInsufficientAmountAdded() public {
        uint amount = 0.002 ether;
        vm.deal(address(this), amount);
        vm.expectRevert(FundMe.FundMe__InsufficientFunds.selector);
        fundMe.addFunds{value: amount}();
    }

    function test_RevertWhenNonOwnerWithdraws() public {
        vm.prank(address(0x123));
        vm.expectRevert(FundMe.FundMe__UnauthorizedError.selector);
        fundMe.withdrawFunds();
    }

    function test_RevertWhenWithdrawnBeforeFundsRaised() public{
       vm.expectRevert(FundMe.FundMe__GoalNotCompletedYet.selector);
       fundMe.withdrawFunds();
    }

    function test_RevertWhenMoreAddedThanNeeded() public {
        uint amount = 3e18;
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
        console.log('Amount withdrawn from the fund me account');
        amountFromFundeMe = msg.value;
    }

    function test_WhenCallerIsAContractWithReceiveEther() public {
        uint amount = 3e18;
        vm.prank(address(0x232));
        vm.deal(address(0x232), amount);
        fundMe.addFunds{value: amount}();
        fundMe.withdrawFunds();
        assertEq(amountFromFundeMe, fundMe.getTotalAddedAmount());
        assertEq(address(fundMe).balance, 0);
    }

    function test_PriceFeedVersionIsAccurate4() public view {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }
}