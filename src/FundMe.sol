// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD_NEEDED = 5 * 1e18;

    address payable public immutable i_owner;
    AggregatorV3Interface private s_dataFeed;

    struct Raiser {
        string name;
        uint256 amountRequired;
        uint256 amountAdded;
    }

    Raiser public s_raise;
    mapping(address => uint256) public s_creditors;

    error FundMe__UnauthorizedError();
    error FundMe__GoalCompleted();
    error FundMe__GoalNotCompletedYet();
    error FundMe__InsufficientFunds();

    constructor(string memory _name, uint256 _amountRequired, address _addr) {
        i_owner = payable(msg.sender);
        s_raise = Raiser(_name, _amountRequired, 0);
        s_dataFeed = AggregatorV3Interface(_addr);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__UnauthorizedError();
        _;
    }
    /**
     * @dev check if the required amount is than the added
     * @dev first convert the receiving amount to USD
     * @dev check if the added amount is more than the MINIMUM_USD_NEEDED
     * @dev if all the above conditions stands then add the amount
     */

    function addFunds() public payable {
        if (s_raise.amountAdded >= s_raise.amountRequired) revert FundMe__GoalCompleted();
        uint256 convertInputToUSD = msg.value.getConversionToUSD(s_dataFeed);
        if (convertInputToUSD < MINIMUM_USD_NEEDED) revert FundMe__InsufficientFunds();
        s_creditors[msg.sender] += msg.value;
        s_raise.amountAdded += msg.value;
    }

    function getNeededAmount() public view returns (uint256) {
        return s_raise.amountRequired;
    }

    function getTotalAddedAmount() public view returns (uint256) {
        return s_raise.amountAdded;
    }

    function getVersion() public view returns (uint256) {
        return s_dataFeed.version();
    }

    function withdrawFunds() public onlyOwner {
        if (s_raise.amountAdded < s_raise.amountRequired) revert FundMe__GoalNotCompletedYet();
        (bool success,) = payable(i_owner).call{value: address(this).balance}("");
        if (!success) revert("Transfer failed");
    }

    receive() external payable {
        addFunds();
    }

    fallback() external payable {
        addFunds();
    }
}
