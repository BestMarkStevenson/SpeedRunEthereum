pragma solidity 0.8.4; // Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "./YourToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vendor is Ownable {
    YourToken public yourToken;

    // Declares that 100 tokens are worth 1 Eth
    uint256 public constant tokensPerEth = 100;

    // Buy Tokens Event
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    // Sell Tokens Event
    event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // Payable buyTokens() function
    function buyTokens() public payable {
        uint256 amountOfETH = msg.value;
        uint256 amountOfTokens = amountOfETH * tokensPerEth;
        _safeTransfer(yourToken, msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, amountOfETH, amountOfTokens);
    }

    // Withdraw function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }

    // Sell Tokens function
    function sellTokens(uint256 amountOfTokens) public {
        uint256 amountOfETH = amountOfTokens / tokensPerEth;
        require(address(this).balance >= amountOfETH, "Insufficient contract balance to complete the sale");

        _safeTransferFrom(yourToken, msg.sender, address(this), amountOfTokens);

        // Using call to transfer ETH
        (bool sent, ) = msg.sender.call{value: amountOfETH}("");
        require(sent, "Failed to send Ether");

        emit SellTokens(msg.sender, amountOfETH, amountOfTokens);
    }

    // Safe transfer function
    function _safeTransfer(IERC20 token, address recipient, uint amount) private {
        bool sent = token.transfer(recipient, amount);
        require(sent, "Token transfer failed");
    }

    // Safe transfer from function
    function _safeTransferFrom(IERC20 token, address sender, address recipient, uint amount) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}