// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wGAS is ERC20 {
    constructor(uint256 initialSupply) public ERC20("WGAS", "wGAS") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}