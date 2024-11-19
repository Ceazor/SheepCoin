// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface ISheep {
    function penTheSheep() external;
    function transferOwnership(address newOwner) external;
    function eatSheep(address _victim, uint256 _amount, address _owner) external;
    function transferFrom(address from, address to, uint256 amount) external;
}