pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGasERC20 is IERC20 {
    function deposit() external payable ;
    function withdraw(uint value) external; 
}