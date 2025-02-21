// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface ISheep {
    function transferOwnership(address newOwner) external;
    function eatSheep(address _victim, uint256 _amount, address _owner, uint256 _mintPercent) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external returns (bool);
    function burnSheep(uint256 balSheepHere) external;
    function owner() external view returns (address);
    function wGasToken() external view returns (address);
}