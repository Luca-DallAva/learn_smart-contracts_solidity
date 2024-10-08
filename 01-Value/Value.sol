// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/** 
* @title Value
* @dev Implement a contract storing a value which can be modiifed while keeping trace of the number of changes 
*      (after the initialization) via a counter.
* Based on https://youtu.be/bNXJNeaYl8Q?si=Jaib7PIvKTdwPXy_
*          https://www.linkedin.com/in/jonathan-spruance-91493a126/                            
*/

// Importing String.sol from openzeppelin library
// This library deals with the transformations uint <-> string <-> int
import "@openzeppelin/contracts/utils/Strings.sol";

contract Value {

   // We initialize the variables
   // First the type of the variable
   // Second the Access Modifier: 
   //                               Public = anyone can see and access it
   //                               Private = anyone can see but can'n access it
   // Third is the name of the variable

   int256 public value; 
   uint256 public counter;
   string public prefix_value = "The value is currently set to ";
   string public prefix_counter = "The number of times the value has been changed is ";

   // The main body of the contract, the constructor function
   // type, data location of the variable (memory = local value, not needed for ints and uints), name of variable input
   // In this example it is a private function, which is called only from the owner of the contract

   constructor(int256 init_value){

       value = init_value;
       counter = 0;
   }

   // Function which sets a new value and increases the counter by 1
   // No return output
   // Change data on the blockchain
   // functions can be public or private (only visible in the present contract)

   function set_value(int256 new_value) public {
       value = new_value;
       counter += 1;
   }

   // Function which returns the value
   // the attribute "view" means that the function does not change data on the blockchain but can read it
   // the attribute "pure" means that the function does not change data on the blockchain and cannot read it
   // One needs to specify the return type

   function get_value() public view returns (string memory) {
       return  string.concat(prefix_value, Strings.toStringSigned(value));
   }

   // Function which returns the counter

   function get_counter() public view returns (string memory) {
       return  string.concat(prefix_counter, Strings.toString(counter));
   }

   // Here we add a the possibility to receive Ehter from an external source.
   // a function "fun" is external if it is only visible externally (can be accessed within the current
   // contract via 'this.fun')
   // the attribute payable means that the function can accept Ether sent to the contract. If not specified,
   // it will reject any transaction
   // This function is executed when a contract receives Ether (without additional data)

   receive() external payable {}

   // One can also define a function for this purpose, we call it "tips"

   function tips() public payable {}

}
