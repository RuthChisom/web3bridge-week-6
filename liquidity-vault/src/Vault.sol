// stores token address, user balances and total liquidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Vault {

    address public token;
    address public factory;

    mapping(address => uint256) public deposits;

    uint256 public totalDeposits;

    constructor(address _token, address _creator) {
        token = _token;
        factory = _creator;
    }

    function deposit(uint256 amount) external {

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;

        totalDeposits += amount;
    }
}