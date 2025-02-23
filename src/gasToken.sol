// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wGAS is ERC20 {
    constructor() public ERC20("WGAS", "wGAS") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint value) public {

    }
}