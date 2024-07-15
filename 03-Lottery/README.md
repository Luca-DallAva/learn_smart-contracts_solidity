#Lottery

Based on 
https://youtu.be/HR679xTt8tg?si=RiO0VQZ3KKEnnG44 and https://youtu.be/_aXumgdpnPU?si=sv6EKTYgh4DXTpzN

RemixAI description:

This Solidity contract is a simple lottery system. It allows users to enter the lottery by sending Ether, with each successful entry being associated with some chance of winning. 

Here's a breakdown of what the different parts do:

1. `address public owner;` - This declares an `owner` variable which is publicly accessible and can be accessed directly without calling any functions. The owner is the one who deployed this contract, set during the construction (`constructor() {...}`).

2. `address payable[] public players;` - This array keeps track of all participants in the lottery. Each participant needs to send at least 1000 Wei (a small Ether amount) when they want to enter, as a requirement.

3. `uint public LotteryId;` - Keeps track of how many times the lottery has been played. It starts from 1 and increases every time a new winner is determined.

4. `mapping (uint => address payable) public LotteryWinner;` - This map keeps track of each individual winnings for each play. For example, if `LotteryWinner[5] = <some address>`, that means the 5th lottery was won by `<some address>`.

5. The `Enter()` function allows users to participate in the lottery by sending Ether to this contract's address (it accepts payments). It checks if the sender has sent at least 1000 Wei, and if so, adds their address to the list of players.

6. The `WinnerExtraction()` function is used by the owner to determine a random winner from the participants in the lottery. This uses a pseudo-random number generator (hash of owner's address, current timestamp, and block hash), then chooses a player based on that index (modulo the total number of players). The winner gets sent all Ether held by this contract.

7. `LotteryHistory()` returns an array of addresses representing winners for each round. 

8. `Prize()` function is public and view, it allows anyone to check how much ether the lottery has left in the smart contract. It does so by returning the current balance of this contract (which equals the total amount of Ether sent to the contract minus what's already been extracted).

9. `PlayersList()` is a function which returns all players currently registered for the next round of lottery, it does not delete them just gives an array with their addresses.
