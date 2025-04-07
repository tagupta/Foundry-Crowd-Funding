// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD_NEEDED = 5 * 1e18;

    address payable public immutable i_owner;
    AggregatorV3Interface private dataFeed;

    struct Raiser {
        string name;
        uint256 amountRequired;
        uint256 amountAdded;
    }

    Raiser public raise;
    mapping(address => uint256) public creditors;

    error FundMe__UnauthorizedError();
    error FundMe__GoalCompleted();
    error FundMe__GoalNotCompletedYet();
    error FundMe__InsufficientFunds();

    constructor(string memory _name, uint256 _amountRequired, address _addr) {
        i_owner = payable(msg.sender);
        raise = Raiser(_name, _amountRequired, 0);
        dataFeed = AggregatorV3Interface(_addr);
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
        if (raise.amountAdded >= raise.amountRequired) revert FundMe__GoalCompleted();
        uint256 convertInputToUSD = msg.value.getConversionToUSD(dataFeed);
        if (convertInputToUSD < MINIMUM_USD_NEEDED) revert FundMe__InsufficientFunds();
        creditors[msg.sender] += msg.value;
        raise.amountAdded += msg.value;
    }

    function getNeededAmount() public view returns (uint256) {
        return raise.amountRequired;
    }

    function getTotalAddedAmount() public view returns (uint256) {
        return raise.amountAdded;
    }

    function getVersion() public view returns (uint256) {
        return dataFeed.version();
    }

    function withdrawFunds() public onlyOwner {
        if (raise.amountAdded < raise.amountRequired) revert FundMe__GoalNotCompletedYet();
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
