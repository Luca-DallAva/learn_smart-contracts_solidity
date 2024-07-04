// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/** 
* @title VendingMachine
* @dev Implement a Vending Machine
* Based on https://youtu.be/bNXJNeaYl8Q?si=Jaib7PIvKTdwPXy_
*          https://www.linkedin.com/in/jonathan-spruance-91493a126/                            
*/

// We define two state variables:
//  - address is the type of variable (size of 1 ETH = 20 bite), we define it to be public and we call it owner; it represents the address 
//    of the owner of the Vending Machine
//  - mapping is a type of variable, here we map (=>) address to uint256 (uint is an alias for that)
// constructor = constructs the smart contracts
// mgs = global variable
// sender is the property of mgs = ehtereum address
// msg.sender in the constructor function will fix the owner as the ethereum address of the deployer of the contract
// we address the owner of the contract while initializing the balance "sodasBalance"; it will also store the info 
// about everyone intereacting with the machine


contract VendingMachine {
    address public owner;
    mapping (address => uint) public sodasBalances;

    constructor() {
        owner = msg.sender;
        sodasBalances[address(this)] = 300;
    }

    function getVendingMachineBalance {}
}
