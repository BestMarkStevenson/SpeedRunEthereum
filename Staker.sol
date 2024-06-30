// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
//Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker 
{
  // sets up contract
  ExampleExternalContract public exampleExternalContract;

  // track individual balances
  mapping ( address => uint256 ) public balances;

  // track a constant threshold at one ether 
  uint256 public constant threshold = 1 ether;

  // creates uint variable for the deadline
  uint256 public deadline =  block.timestamp + 72 hours; // sets the deadline to 72 hours from deployment
 
  // event for the Stake(address,uint256) event and emit it for the frontend `All Stakings` tab to display)
  event Stake(address, uint256);

  // event for the withdraw function
  event Withdraw(address,uint256);

  // boolean variable for if user can withdraw
  bool public openForWithdraw = false;

  // constructs contract
  constructor(address exampleExternalContractAddress) 
  {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);

  }


  // payable `stake()` function that tracks individual `balances` with a mapping:
  function stake() public payable 
  {
    // update the user's balance
    balances[msg.sender] += msg.value;

    // emit the event to notify the blockchain that we have correctly Staked some fund for the user
    emit Stake(msg.sender, msg.value);
  }

  // met threshold function
  function metThreshold() public view returns (bool) 
  {
    return address(this).balance >= threshold;
  }



  // execute() function that can be called on after the deadline which calls `exampleExternalContract.complete{value: address(this).balance}()` 
  function execute() public returns(uint256)
  {
    if (!metThreshold())
    {
      openForWithdraw = true;
      return 1;
    }
    if (block.timestamp >= deadline)
    {
      exampleExternalContract.complete{value: address(this).balance}();
      return 0;
    }
    openForWithdraw = false;
    return 1;

  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public 
  {
    require(block.timestamp >= deadline, "Dealine not reached yet");
    require(!metThreshold(), "Threshold not met yet");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "you don't have a balance");
    (bool sent,) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send Ether");
    balances[msg.sender] = 0;
    emit Withdraw(msg.sender, amount);

  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) 
  {
    if (block.timestamp >= deadline)
    {
      return 0;
    }
    else 
    {
      return deadline - block.timestamp;
    }
    
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable 
  {
    stake();
  }

}