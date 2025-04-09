// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    uint256 amountFromFundeMe;
    address USER = makeAddr("alice");
    uint256 constant SEND_VALUE = 5e18;
    uint256 constant STARTING_BALANCE = 1e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        FundMeScript script = new FundMeScript();
        fundMe = script.run();
        vm.deal(address(fundMe), 0);
    }

    function testUserCanFundWithInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        uint256 balanceBefore = msg.sender.balance;

        fundFundMe.fundFundMe(address(fundMe));
        uint256 balanceAfter = msg.sender.balance;

        assertEq(SEND_VALUE, address(fundMe).balance);
        assertApproxEqRel(balanceBefore - balanceAfter, 5e18, 0.05e16);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
