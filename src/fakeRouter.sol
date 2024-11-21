// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/IRouter.sol";
 

pragma solidity ^0.8.13;

contract FAKEROUTER{

    function swapExactTokensForTokensSimple(uint amountIn, uint amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint deadline) external returns (uint[] memory amounts){
        IERC20(tokenFrom).transferFrom(msg.sender, address(this), amountIn);
        uint256 swapAmt = amountIn * 10 /  100;
        IERC20(tokenTo).transfer(to, swapAmt);
    }

}