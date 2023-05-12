// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface ILP {
    function approve(address spender, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function balanceOf(address owner) external view returns(uint256);

}