pragma solidity 0.8.13;

interface IRouter {
    function swapExactTokensForTokensSimple(uint amountIn, uint amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint deadline) external returns (uint[] memory amounts);

}
