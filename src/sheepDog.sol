// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/ISheep.sol";
import "src/interfaces/IRouter.sol";

pragma solidity ^0.8.13;

contract SHEEPDOG is Ownable, ReentrancyGuard{
    address public sheep;
    
    uint public totalShares;

    mapping(address => uint256) public sheepDogShares;
    mapping(address => uint256) public sheepToClaim;
    mapping(address => uint256) public wenToClaim;
    mapping(address => uint256) public rentStart;
    address public wGasToken;
    address public router;

    constructor(address _sheep,address _router)  {
        sheep = _sheep;
        wGasToken = ISheep(sheep).wGasToken();
        router = _router;
    }

     //Buy SHEEP with gasToken
    function buySheep() public {

        uint256 balGasToken = IERC20(wGasToken).balanceOf(address(this));
        uint teamFee = balGasToken * 5 / 100;
        uint buyAmount = balGasToken - teamFee;

        IERC20(wGasToken).transfer(ISheep(sheep).owner(), teamFee);
        
        IERC20(wGasToken).approve(router,buyAmount);
        IRouter(router).swapExactTokensForTokensSimple(balGasToken, 1e18, wGasToken, sheep, false, address(this), block.timestamp + 10);
  
    }

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
    function dogSleep() public {
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