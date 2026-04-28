# Split Bill Smart Contract

## Overview

This project is a decentralized expense splitting application that allows users to create groups, add shared expenses, track balances, and settle debts on-chain without relying on trust.

## Features

* Create groups
* Add members
* Add shared expenses
* Track who owes whom
* Optimized debt settlement using simplification logic
* Batch settlement in a single transaction

## Unique Feature

Unlike traditional expense-splitting applications, this project reduces the number of transactions required to settle debts by applying debt simplification logic based on graph principles.

## Tech Stack

* Solidity
* Remix IDE
* MetaMask
* Sepolia Testnet

## Contract Address (Sepolia)

0x6C4170B8cC867637D3ECD9AbA9E7C0A6291bD9Bb

## How It Works

1. A user creates a group.
2. Members are added to the group.
3. Expenses are recorded and split among participants.
4. The contract tracks balances between users.
5. Debts are settled using optimized batch transactions.

## Edge Case Handling

* Prevents duplicate members
* Ensures only group members can perform actions
* Prevents overpayment and incorrect transaction amounts
* Validates participant addresses
* Handles rounding during expense division

## Smart Contract

See SplitBillOptimized.sol
