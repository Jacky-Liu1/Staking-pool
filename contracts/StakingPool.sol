//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract StakingPool {
    address public owner;
    uint256 public end;
    bool public finalized;
    uint256 public totalInvested;
    uint256 public totalChange;

    mapping(address => uint256) public balances;
    mapping(address => bool) public changeClaimed;

    event NewInvestor(address investor);

    constructor() {
        owner = msg.sender;
        end = block.timestamp + 10 days;
    }

    function invest() external payable {
        require(block.timestamp < end, "investing period has passed");
        if (balances[msg.sender] == 0) {
            emit NewInvestor(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    function finalize() external {
        require(block.timestamp >= end, "too early");
        require(finalized == false, "already finalized");
        finalized = true;
        totalInvested = address(this).balance;
        totalChange = address(this).balance % 32 ether;
    }

    function getChange() external {
        // up to each investor to get their change if totalInvested > 32 eth
        require(finalized == true, "not finalized");
        require(balances[msg.sender] > 0, "not an investor");
        require(changeClaimed[msg.sender] == false, "already claimed");
        changeClaimed[msg.sender] = true;
        uint256 amount = (totalChange * balances[msg.sender]) / totalInvested;
        payable(msg.sender).transfer(amount);
    }
}
