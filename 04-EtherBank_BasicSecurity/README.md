# Ether Bank and basic security practices

We implement an Ether bank which allows the user to:
    - deposit Ether of the user
    - withdraw all Ether previously deposited by the user
    - buy and sell bonds, with price (in ether) and rate fixed by the bank:
      -- the purchased bond can be sold only after 1 week from the purchase
      -- only one bond can be owned by a user at any time

THE CODE IN `FaultyBank.sol` PRESENTS SEVERAL ISSUES, AND IT IS MEANT AS A LEARNING TOOL FOR TWO ATTACKS: FAULTY ACCESS CONTROL AND REENTRANCY ATTACK.

The main sources I follow are https://www.youtube.com/@BlockExplorerMedia and http://www.youtube.com/@smartcontractprogrammer.
The first is Jonathan Spruance's YouTube channel (https://www.linkedin.com/in/jonathan-spruance-91493a126/). 
See also his GitHub repository: https://github.com/jspruance/block-explorer-tutorials/tree/main/smart-contracts/solidity.
The second refers to https://github.com/t4sk/, https://solidity-by-example.org, and https://www.smartcontract.engineer.


## Faulty Bank: FaultyBank.sol

This Solidity contract, FaultyBank, is a basic implementation of an Ether-based bank that allows users to:

- Deposit Ether: Users can deposit Ether into the contract.
- Withdraw Ether: Users can withdraw all Ether previously deposited.
- Buy and Sell Bonds: Users can buy bonds at a fixed price and sell them after a 1-week lock period. Only one bond can be owned by a user at any time.

A thourough description of the functions can be read in Ether Bank (see below).

This contract is intentionally designed with potential issues to serve as a learning tool for:

- Faulty Access Control: Functions lack access control mechanisms, making them susceptible to unauthorized use. In particular the functions `SetBondPrice` and `SetBondPercentage`.
- Reentrancy Attack: The `Withdraw` and `Transfer` functions are vulnerable to reentrancy attacks, as they do not use any protective mechanisms (like OpenZeppelin's ReentrancyGuard).

This contract is not secure and is intended for educational purposes.

## Ether Bank

We take preventive measure to avoid reentrancy attacks as well as access control ones. 

### EtherBank Solidity Smart Contract

#### Overview

The EtherBank smart contract is an Ethereum-based decentralized bank that allows users to deposit and withdraw Ether, as well as buy and sell bonds. The contract implements protections against common smart contract vulnerabilities such as reentrancy attacks and faulty access control.

This contract is designed as a learning tool, showcasing how to mitigate security issues while building decentralized financial applications on Ethereum. It includes functionalities for managing Ether deposits, withdrawals, and bond purchases, along with access control mechanisms to ensure only authorized actions are performed by the contract owner.

#### Key Features

- Deposit Ether: Users can deposit Ether into the contract, which is tracked in their personal balance.
- Withdraw Ether: Users can withdraw the Ether they have deposited into the contract, with protections against reentrancy attacks.
- Buy and Sell Bonds:
    - Users can buy bonds at a fixed price and interest rate determined by the contract owner.
    - Bonds can only be sold after a 1-week lock period from the time of purchase. Each user can only hold one bond at a time.
- Time Lock: The bond lock period is enforced through time locks, preventing the bond from being sold before the lock period ends.

#### Security Measures: 

The contract is designed with protections against reentrancy and faulty access control attacks, utilizing OpenZeppelin's ReentrancyGuard and custom access control modifiers.

#### Contract Details

##### Mappings
- balances: Tracks Ether balances for each user.
- bonds: Tracks whether a user owns a bond.
- lock_time: Tracks the lock period for bonds, preventing them from being sold too early.
- increments: Tracks whether a user has increased their bond lock time (limited to one increment per user).

##### Variables
- owner: The contract owner, who is granted special permissions to set bond prices and percentages.
- bond_price: The price of a bond in Ether.
- bond_percentage: The interest rate of the bond.
- fee: The fee collected by the contract owner when a bond is purchased.

##### Functions
- Constructor: Initializes the contract with initial bond price and percentage, and requires an initial deposit of at least 1 Ether by the owner.
- SetBondPrice: Allows the owner to update the bond price.
- SetBondPercentage: Allows the owner to update the bond interest rate.
- Deposit: Allows users to deposit Ether into their balance.
- Withdraw: Allows users to withdraw their Ether, with protection against reentrancy attacks.
- Transfer: Internal function to transfer Ether between users with reentrancy protection.
- BuyBond: Allows users to buy a bond, deducting the bond price and fee from their balance.
- SellBond: Allows users to sell their bond after the lock period, transferring the bond's value plus interest back to them.
- IncreaseTime: Allows users to extend the bond lock period once, with a small reward for doing so.

##### Getter Functions
- Balance: Returns the total Ether balance held by the contract.
- Bond: Returns whether the caller owns a bond.
- BondPrice: Returns the current bond price.
- BondPercentage: Returns the current bond interest rate.
- Fee: Returns the fee collected by the owner on bond purchases.
- TimeLock: Returns the remaining lock time on the caller's bond, or 0 if the bond is no longer locked.

#### Security
Reentrancy Protection: The contract uses OpenZeppelin's ReentrancyGuard to protect against reentrancy attacks in critical functions like withdrawals and transfers.
Access Control: The Ownership modifier restricts certain actions, such as setting bond prices, to the contract owner only.

## Access Control Attack: AccessControlAttack.sol

`AccessControlAttack` is a malicious Ethereum smart contract designed to demonstrate an access control attack on the `FaultyBank` contract. It interacts with the `FaultyBank` contract, exploiting weak access controls by allowing unauthorized changes to the bond price and percentage.

#### Key functionalities include:

- Attack Function: The attacker changes the bond price and percentage of the `FaultyBank` contract to zero, buys a bond, and then restores the original values.
- Ownership Modifier: Ensures that only the contract owner can execute the attack.

This contract showcases vulnerabilities related to faulty access control in smart contracts

## Reentrancy Attack: ReentrancyAttack.sol

`ReentrancyAttack` is a malicious smart contract designed to exploit a reentrancy vulnerability in the `FaultyBank` contract. The goal of the attack is to repeatedly withdraw funds from the vulnerable contract before the initial withdrawal is completed, allowing the attacker to drain the bank's balance.

#### Key functionalities include:

- Attack Function: Initiates the attack by depositing Ether into the `FaultyBank` contract and then calling the withdrawal function to exploit the reentrancy bug.
- Receive Function:  Handles incoming Ether and reenters the `FaultyBank` withdrawal function if the contract still has funds, enabling continuous draining until the contract is depleted.

This contract demonstrates how reentrancy attacks can be used to exploit improperly designed withdrawal mechanisms in Ethereum smart contracts.


