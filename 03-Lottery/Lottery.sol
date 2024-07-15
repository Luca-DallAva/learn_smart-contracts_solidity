// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/** 
* @title Lottery
* @dev Implement a Lottery system
* Based on https://youtu.be/HR679xTt8tg?si=RiO0VQZ3KKEnnG44
*          https://youtu.be/_aXumgdpnPU?si=sv6EKTYgh4DXTpzN                            
*          https://www.linkedin.com/in/jonathan-spruance-91493a126/
*/

// 


contract Lottery {
    address public owner;
    address payable[] public players; // The palyers must be able to receive prices, so we add "payable"
    uint public LotteryId; //Variable to keep track of number of extractions
    mapping (uint => address payable) public LotteryWinner; // We keep track of the winner at each extraction. 
                                                             // Hence we define a map returning the winner of the n-th extraction
                                                             // for n the input
    constructor() {
        owner = msg.sender;
        LotteryId = 1; // Set to 1
    }

    // The function returning the balance of the contract, that is, our prize

    function Prize() public view returns (uint) {
        return address(this).balance;
    }


    // The function returning the players; memory as we do not want to store this value

    function PlayersList() public view returns (address payable[] memory) {
        return players;
    }

    // The function which adds a new player to the lottery
    // called "Enter" as it will add the sender address to the vector of players
    // note that we add payable as ?

    function Enter() public payable{
        
        // we require that the value of the transaction sent by the msg sender, is enough
        // msg.value is the field taking care of this value
        require(msg.value >= 1000 wei);
        
        // we add the address to the vector of players
        players.push(payable (msg.sender) );        //push() is a function of the array

    }

    // Pseudo-random number function
    
    function PseudoRandomNumber_hash() public view returns(uint){
        // We use an hashing algorithm native in solidity
        // This is not really secure, as the randomness is not good enough for real applications

        // abi.encodePacked alllows to concatenate two or more strings
        // we pass the owner address as well as the timestamp of the present block and the hask of the present block
        // IT IS NOT RANDOM! IT IS ACTUALLY POSSIBLE TO COMPUTE SUCH VALUES
        // One mightwnat to use a VRF, on or off-chain:
        // https://medium.com/coinmonks/how-to-generate-random-numbers-in-solidity-16950cb2261d
        // see also https://docs.chain.link/vrf

        return uint(keccak256(abi.encodePacked(owner,block.timestamp,blockhash(block.number))));
    }

    // We create a reusable modifier, that is an alias for the requirement "require(msg.sender == owner);"
    // That is, we restrict the call of this function to the owner of the contract

    modifier OnlyTheOwner() {

        require(msg.sender == owner, "Caller is not the owner");

        // The underscore means that, whenever we add the attribute OnlyTheOwner,
        // we reference all the code inside the addressed function
        // This means that the attribute is adding the fist line to the function
        _;
    }

    // The function which returns the winner of the present extraction. 
    // It relies on the extraction of a (pseudo-)random number
    // We restrict the call of this function to the owner of the contract
    // We use the modifier OnlyTheOwner we introduced above

    function WinnerExtraction() public OnlyTheOwner {

        require(players.length > 0, "No players in the lottery");
        require(Prize() >= 1000 wei, "The prize is too low");

        // We reset the players array before transferring to save gas
        // the function "delete" is used to delete an array, in this case, we delete the variable "players"
        // we associate an index to the pseudo random number we consider

        // % stands for the reduction modulo an integer, in this case, the length of the array of players
        // with the reduction modulo an integer we do not have to shift the index, as arrays are indexed 
        // starting with 0

        uint index = PseudoRandomNumber_hash() % players.length;
        address payable winner = players[index];

        // We transfer the total amount to the winning player
        // Pay attention to reentrancy attacks (attacker calls recursively the tranfer operation): 
        // see e.g. https://blog.chain.link/reentrancy-attacks-and-the-dao-hack/
        // It's good practice to first transfer, then update the state
        winner.transfer(address(this).balance);

        // We keep track of the winner of the LotteryId-th extraction
        LotteryWinner[LotteryId] = winner;

        LotteryId++; // Syntax for LotteryId += 1;
        
        // Reset players array before transferring to save gas
        // We reset the array for the next extraction, that is, we reset the state of the contract
        players = new address payable[](0);  // reset to a length 0 array
    }

    // Function which returns an array of the winners, from the first winner until the last one.

    function LotteryHistory() public view returns (address payable[] memory) {
         address payable[] memory Winners = new address payable[](LotteryId-1);
         for (uint i = 0; i < LotteryId-1; i++){
            Winners[i] = LotteryWinner[i+1];
         }
         return Winners;
    }
}


