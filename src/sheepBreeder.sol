// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/IRouter.sol";
 

pragma solidity ^0.8.13;

contract SHEEPBREEDER is Ownable, ReentrancyGuard{
    address public sheep;
    address public wGasToken;
    address public router;
    mapping(address => uint256) public owedSheep;
    mapping(address => uint256) public wenBorn;
    mapping(address => bool) public breeding;
    uint256 lambBal = 0;

    uint256 constant ONE = 1 * 1e18;
    uint256 constant TWO = 2 * 1e18;
    uint256 constant THREE = 3 * 1e18;

    constructor(address _sheep, address _gasToken, address _router) {
        sheep = _sheep;
        wGasToken = _gasToken;
        router = _router;
    }
    //Buy SHEEP with gasToken
    function buySheep() public {
        uint256 balGasToken = IERC20(wGasToken).balanceOf(address(this));
        IERC20(wGasToken).approve(router,balGasToken);

        uint256 sheepBalBefore = IERC20(sheep).balanceOf(address(this));
        IRouter(router).swapExactTokensForTokensSimple(balGasToken, ONE, wGasToken, sheep, false, address(this), block.timestamp + 10);
        uint256 sheepBalAfter = IERC20(sheep).balanceOf(address(this));
        uint256 sheepNewAdd = sheepBalAfter - sheepBalBefore; 

        lambBal = lambBal + sheepNewAdd; 

    }

    // Breed your sheep with the Sheep breeder. 2 for 3
    function breed() public nonReentrant{
        if (IERC20(wGasToken).balanceOf(address(this)) >= ONE){
            buySheep();
        }
        if (lambBal >= ONE && !breeding[msg.sender]){
            IERC20(sheep).transferFrom(msg.sender, address(this), TWO);
            owedSheep[msg.sender] += THREE;
            wenBorn[msg.sender] = block.timestamp + 86400;
            lambBal -= ONE;
        }

    }
    // Get your sheep back and their baby
    function getSheep() public {
        require(block.timestamp >= wenBorn[msg.sender], "your sheep are not finished breeding");
        uint256 sheepAmt = owedSheep[msg.sender]; 
        IERC20(sheep).transfer(msg.sender, sheepAmt);
        owedSheep[msg.sender] = 0;
        lambBal = IERC20(sheep).balanceOf(address(this));
    }
}