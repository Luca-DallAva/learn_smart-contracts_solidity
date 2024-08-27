// SPDX-License-Identifier: MIT
/*
    We implement an Ether bank which allows the user to:
    - deposit Ether of the user
    - withdraw all Ether previously deposited by the user
    - buy and sell bonds, with price (in ether) and rate fixed by the bank:
      -- the purchased bond can be sold only after 1 week from the purchase
      -- only one bond can be owned by a user at any time

    THIS CODE PRESENT SEVERAL ISSUES, AND IT IS MEANT AS A LEARNING TOOL FOR TWO ATTACKS:
    FAULTY ACCESS CONTROL AND REENTRANCY ATTACK.
*/

pragma solidity ^0.8.19;

import "hardhat/console.sol"; // We want to print messages on the console.
import "@openzeppelin/contracts/utils/Address.sol"; // Library for sendValue etc. https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol


contract FaultyBank {

    // Mappings

    // initialize the mapping which keeps track of the balances
    mapping (address  => uint) public  balances;
    // initialize the mapping which keeps track of all the purchased bonds
    mapping (address => bool) public  bonds;
    // initialize the mapping which keeps track of all the time locks after purchasing a bond
    mapping (address => uint) public  lock_time;
    // initialize the mapping which keeps track of all the time locks increments
    mapping (address => bool) public  increments;

    // Variables

    address payable public immutable owner; // the owner, immutable
    uint256 public bond_price; // price of the bond
    uint256 public bond_percentage; // percentage of the bond
    uint256 public fee; // fee the owner receives after a bond is purchased

    // contructor function called at the creation of the contract
    // we initialize the variables bond_price and bond_percentage to an initial states
    // need to add payable so that we can require an initial transfer of ether
    constructor (uint256 init_bond_price, uint256 init_bond_percentage) payable  {
        uint256 amount = msg.value;
        require(amount >= 1 ether, "Must send at least 1 ether");

        owner = payable(msg.sender); // Set the contract deployer as the owner
        bond_price = init_bond_price * ( 1 ether );
        bond_percentage = init_bond_percentage;
        fee = (bond_price *  bond_percentage) / (2 * 100); //half of the bond_percentage of the bond price
        
        // we  deposit the amount on the owner balance
        balances[owner] += amount;
        console.log("Deposit from %s for %d", owner, amount);
        console.log("Contract initialized and deployed.");
    }

    // function for re-setting bond_price
    function SetBondPrice(uint256 new_bond_price) public {
        bond_price = new_bond_price;
        fee = (bond_price *  bond_percentage) / (2 * 100);  // update fee
        console.log("New bond price set successfully to %d", bond_price);
    }

    // function for re-setting bond_price
    function SetBondPercentage(uint256 new_bond_percentage) public {
        bond_percentage = new_bond_percentage;
        fee = (bond_price *  bond_percentage) / (2 * 100);  // update fee
        console.log("New bond percentage set successfully to %d", bond_percentage);
    }


    // function for deposit //public as we call it externally and internally
    function Deposit() public payable {
        // get the address of the sender and the amount deposited by the sender
        address user = msg.sender;
        uint256 amount = msg.value;
        console.log("Deposit from %s for %d", user, amount);

        // add the amount deposited by user in balances mapping 
        balances[user] += amount;
        console.log("Balance of %s is %d", user, balances[user]);

        console.log("Ether sent successfully.");
    }

    // function for withdraw
    function Withdraw() external payable {
        // get the address of the sender, we make it payable
        address user = msg.sender;
        // we require that the sender has ether to withdraw
        require(balances[user] > 0, "Withdrawl amount exceeds the balance.");
        console.log("");
        console.log("Bank balance: ", address(this).balance);
        console.log("User balance: ", balances[user]);
        console.log("");
        // We process the transfer
        (bool success, ) = payable(msg.sender).call{value: balances[user]}("");
        require(success, "Transfer failed.");
        // subtract this amount from balances mapping 
        balances[user] = 0;
        console.log("Withdrawal completed successfully.");
        console.log("User balance: ", balances[user]);
        console.log("");
    }

    // function for transfering money from one account to the other, it is internal
    function Transfer(uint256 amount, address source, address target) internal {
        // there must be enough ether
        require(balances[source] - amount >= 0);
        balances[source] -= amount;
        balances[target] += amount;
    }

    // function for buying a bond
    function BuyBond() external payable {
        // get the address of the sender and the amount deposited by the sender
        address user = msg.sender;
        // we require the user to not already own a bond
        require(!bonds[user], "The sender already owns a bond.");
        if (balances[user] < bond_price + fee) {
            // we look at the deposited amount
            uint256 amount = msg.value;
            require(amount >= bond_price + fee, "The amount does not cover the price of the bond and the fee.");
            Deposit(); // we deposit the amount
        }
        //require(balances[user] >= bond_price + fee, "The deposited amount does not cover the price of the bond and the fee.");
        balances[user] -= bond_price - fee;
        balances[owner] += fee;
        bonds[user] = true;
        console.log("");
        console.log("The bond has been purchased.");
        console.log("User balance: ", balances[user]);
        console.log("");
        // we must set the "timer" which locks the bond for a certain amount of time (in this case 1 week)
        lock_time[user] = block.timestamp + 1 weeks; //30;// 30 seconds for testing // block.timestamp returns the present time
    }

    // function for selling a bond
    function SellBond() external payable {
        // get the address of the sender and the amount deposited by the sender
        address user = msg.sender;
        require(bonds[user], "One must first buy a bond.");
        require(block.timestamp > lock_time[user], "Lock time not expired yet.");
        // define the selling price
        uint256 selling_price = bond_price*(1 + bond_percentage/100);
        (bool success, ) = payable(user).call{value: selling_price}("");
        require(success, "The bond has been sold.");
        bonds[user] = false;
    }

    // function for increasing the locked time
    // if the waiting time is more than 1 weeks, then we transfer 1/1000 of the bond price to the msg.sender deposit
    // we require that this increment can be done just once
    function IncreaseTime(uint256 increment) external {
        address user = msg.sender;
        require(bonds[user], "One must buy a bond.");
        require(!increments[user], "Only one increment is allowed for each bond.");
        lock_time[user] += increment;
        // only one increment is allowed
        increments[user] = true;
        // we deposit the prize
        Transfer(bond_price/1000, owner, user);
    }

    // Getter functions:

    // function for returning the balance of the bank
    function Balance() external view returns (uint256) {
        return address(this).balance;
    }

    // function returning the boolean for the bond mapping of the msg.sender
    function Bond() external view returns (bool) {
        return bonds[msg.sender];
    }

    // function returning the present bond price
    function BondPrice() external view returns (uint256) {
        return bond_price;
    }

    // function returning the present bond percentage
    function BondPercentage() external view returns (uint256) {
        return bond_percentage;
    }

    // function returning the present bond fee
    function Fee() external view returns (uint256) {
        return fee;
    }

    // function returning the waiting time in seconds if the sender has purchased a bond
    // 0 if the sender does not have bonds or the locked time has expired
    function TimeLock() external view returns (uint256) {
        address user = msg.sender;
        if (bonds[user]) {
            uint256 time = block.timestamp;
            uint256 lockedtime = lock_time[user];
            if (time >= lockedtime) {
                return 0;
            } else {
                uint256 remaining_secs = lockedtime - time;
                return remaining_secs;
            }
        } else {
            return  0;
        }
        
    }
}