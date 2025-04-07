// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter} from './PriceConverter.sol';

contract FundMe {

    using PriceConverter for uint256;

    uint constant public MINIMUM_USD_NEEDED = 5 * 1e18;

    address payable immutable i_owner;

    struct Raiser{
        string name;
        uint amountRequired;
        uint amountAdded;
    }

    Raiser public raise;
    mapping(address => uint) public creditors;
    
    error FundMe__UnauthorizedError();
    error FundMe__GoalCompleted();
    error FundMe__GoalNotCompletedYet();
    error FundMe__InsufficientFunds();

    constructor(string memory _name, uint _amountRequired){
        i_owner = payable(msg.sender);
        raise = Raiser(_name, _amountRequired, 0);
    }

    modifier onlyOwner(){
        if(msg.sender != i_owner) revert FundMe__UnauthorizedError();
        _;
    }
    /**
    * @dev check if the required amount is than the added
    * @dev first convert the receiving amount to USD
    * @dev check if the added amount is more than the MINIMUM_USD_NEEDED
    * @dev if all the above conditions stands then add the amount 
    */
    function addFunds() public payable {
        if(raise.amountAdded >= raise.amountRequired) revert FundMe__GoalCompleted();
        uint convertInputToUSD = msg.value.getConversionToUSD();
        if(convertInputToUSD < MINIMUM_USD_NEEDED) revert FundMe__InsufficientFunds();
        creditors[msg.sender] += msg.value;
        raise.amountAdded += msg.value;
    }
    function getNeededAmount() public view returns(uint256){
        return raise.amountRequired;
    }

    function getTotalAddedAmount() public view returns(uint) {
        return raise.amountAdded;
    }

    function withdrawFunds() public onlyOwner{
        if(raise.amountAdded < raise.amountRequired) revert FundMe__GoalNotCompletedYet();
        (bool success, ) = payable(i_owner).call{value: address(this).balance}("");
        if(!success) revert("Transfer failed");
    }

    receive() external payable {
       addFunds();
    }

    fallback() external payable {
        addFunds();
    }
}