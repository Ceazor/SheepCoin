// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IRouter {
  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline) external;
}