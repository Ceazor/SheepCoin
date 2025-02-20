// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/IPair.sol";
 

pragma solidity ^0.8.13;

contract FAKEPAIR{

    uint public reserve0;
    uint public reserve1;

    address token0;
    address token1;

    constructor(address _token0,address _token1) public {
        token0 = _token0;
        token1 = _token1;
    }

    function sync() external {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
    }

}