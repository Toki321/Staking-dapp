// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor () ERC20("Reward Token", "RT") {
        _mint(msg.sender, 100000 * 10**18);
    }
}