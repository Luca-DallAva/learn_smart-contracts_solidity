// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/** 
* @title VendingMachine
* @dev Implement a Vending Machine
* Based on https://youtu.be/bNXJNeaYl8Q?si=Jaib7PIvKTdwPXy_
*          https://www.linkedin.com/in/jonathan-spruance-91493a126/                            
*/

// We define two state variables:
//  - address is the type of variable (size of 1 ether = 20 bite), we define it to be public and we call it owner; it represents the address 
//    of the owner of the Vending Machine
//  - mapping is a type of variable, here we map (=>) address to uint256 (uint is an alias for that)
// constructor = constructs the smart contracts
// mgs = global variable
// sender is the property of mgs = ehtereum address
// msg.sender in the constructor function will fix the owner as the ether address of the deployer of the contract
// we address the owner of the contract while initializing the balance "sodasBalance"; it will also store the info 
// about everyone intereacting with the machine


contract VendingMachine {
    address public owner;
    mapping (address => uint) public sodasBalances;
    mapping (address => uint) public snacksBalances;

    constructor() {
        owner = msg.sender;
        sodasBalances[address(this)] = 100;
        snacksBalances[address(this)] = 50;
    }

    // Return the number of sodas left

    function getSodasBalance() public view returns (uint) {
        return sodasBalances[address(this)];
    }

    // Return the number of snacks left

    function getSnacksBalance() public view returns (uint) {
        return snacksBalances[address(this)];
    }

    // Return the number of sodas and snacks left

    function getItemsBalance() public view returns (uint) {
        return (sodasBalances[address(this)] + snacksBalances[address(this)]);
    }

    // Funcition restocking the items in the vending machine, it takes two parameters, 
    // the first it the amount of sodas to be restocked, the second one is the amount os snacks to be restocked
    // require is the requirement that only the owner is allowed to restock: 
    //  - the first entry is the condition
    //  - the second one it the error message
    // We increment the amount with += (as usual)

    function restock(uint amount_sodas, uint amount_snacks) public {
        require(msg.sender == owner, "Only the owner of the vending machine can restock it.");
        sodasBalances[address(this)] += amount_sodas;
        snacksBalances[address(this)] += amount_snacks;
    }

    // Function for purchasing sodas. It takes one parameter, the amount
    // payable allows the functions to take 
    // we also incerement the amount of sodas/snacks bought by the user calling the function
    // We require that the payment is processed and the amount of ether is enough, msg.value is the amount we look at
    // The second requirement checks that there are enough items to sell

    function purchase_sodas(uint amount) public payable {
        require(msg.value >= amount * 2, "Each soda costs 2 ether.");
        require(sodasBalances[address(this)]>=amount, "Not enough sodas in stock!");
        sodasBalances[address(this)] -= amount;
        sodasBalances[msg.sender] += amount;
    }

    // Function for purchasing snacks. It takes one parameter, the amount

    function purchase_snacks(uint amount) public payable {
        require(msg.value >= amount * 3, "Each snack costs 3 ether.");
        require(snacksBalances[address(this)]>=amount, "Not enough snacks in stock!");
        snacksBalances[address(this)] -= amount;
        snacksBalances[msg.sender] += amount;
    }

    // FINAL NOTE: ONE MUST ACCOUNT FOR GAS FEES!

}
