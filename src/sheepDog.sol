// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/ISheep.sol";

pragma solidity ^0.8.13;

contract SHEEPDOG is Ownable, ReentrancyGuard{
    address public sheep;
    
    uint public totalShares;

    mapping(address => uint256) public sheepDogShares;
    mapping(address => uint256) public sheepToClaim;
    mapping(address => uint256) public wenToClaim;
    mapping(address => uint256) public rentStart;
    address public wGasToken;

    constructor(address _sheep)  {
        sheep = _sheep;
        wGasToken = ISheep(sheep).wGasToken();
    }

     //Buy SHEEP with gasToken
    // function buySheep() public {
    // todo get the team fee here
    //     uint256 balGasToken = IERC20(wGasToken).balanceOf(address(this));
    //     IERC20(wGasToken).approve(router,balGasToken);

    //     uint256 sheepBalBefore = IERC20(sheep).balanceOf(address(this));
    //     IRouter(router).swapExactTokensForTokensSimple(balGasToken, ONE, wGasToken, sheep, false, address(this), block.timestamp + 10);
    //     uint256 sheepBalAfter = IERC20(sheep).balanceOf(address(this));
    //     uint256 sheepNewAdd = sheepBalAfter - sheepBalBefore; 

    //     lambBal = lambBal + sheepNewAdd; 

    // }

    // Project your sheep with a SheepDog. But you have to pay 1% to the trainer
    function protect(uint256 _amount) public nonReentrant{
        require(wenToClaim[msg.sender] == 0,"dog is going to sleep");

        uint256 totalsheep = totalSheepBalance();
        if (totalShares == 0 || totalsheep == 0) {
            sheepDogShares[msg.sender] += _amount;
            totalShares += _amount;
        } else {
            uint256 what = _amount * (totalShares) / (totalsheep);
            sheepDogShares[msg.sender] += what;
            totalShares += what;
        }
        ISheep(sheep).transferFrom(msg.sender, address(this), _amount);
        if (rentStart[msg.sender] == 0){
            rentStart[msg.sender] = block.timestamp;
        }
    }

    // Put your sheepDog to sleep so you can move the sheep.
    function dogSleep(uint256 _share) public {
        require(wenToClaim[msg.sender] == 0,"dog is going to sleep");
        require(sheepDogShares[msg.sender] != 0,"no sheeps");

        wenToClaim[msg.sender] = block.timestamp + 172800; // 2 days
    }
    // Get your sheep back. User will need to pay 10 wGasTokens / day since they deposited. 5% ove these are sent to team, and 95% are sent to the breeder
    function getSheep() public {
        require(wenToClaim[msg.sender] != 0, "put dog to sleep fist");
        require(block.timestamp >= wenToClaim[msg.sender], "your sheepDog is not asleep yet");

        uint256 what = sheepDogShares[msg.sender] * (totalSheepBalance()) / (totalShares);

        ISheep(sheep).transfer(msg.sender, what);
        uint256 payRent = getCurrentRent(msg.sender);

        IERC20(wGasToken).transferFrom(msg.sender, address(this), payRent);

        rentStart[msg.sender] = 0;
        wenToClaim[msg.sender] = 0;

        totalShares -= sheepDogShares[msg.sender];
        sheepDogShares[msg.sender] = 0;

    }
    ///////////////////////////////////////////////
    /////////READ FUNCTIONS////////////////////////
    ///////////////////////////////////////////////

    function getCurrentRent(address _user) public view returns (uint256 _currentRent) {
        uint256 _calcRent = (block.timestamp - rentStart[_user]) / 86400 * 10 * 1e18;
        return _calcRent;
    }

    function totalSheepBalance() public view returns (uint256) {
        return IERC20(sheep).balanceOf(address(this));
    }
}