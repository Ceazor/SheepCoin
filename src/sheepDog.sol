// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "src/interfaces/ISheep.sol";
import "src/interfaces/IRouter.sol";

pragma solidity ^0.8.13;

//Sheepdog is an APR vault for SHEEP that is safe from the wolf

contract SHEEPDOG is Ownable2Step, ReentrancyGuard{
    address public sheep;
    
    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;

    uint public totalShares;
    uint public totalSheep;

    mapping(address => uint256) public sheepDogShares;
    mapping(address => uint256) public wenToClaim;
    mapping(address => uint256) public rentStart;
    address public wGasToken;
    address public router;

    constructor(address _sheep,address _router)  {
        sheep = _sheep;
        wGasToken = ISheep(sheep).wGasToken();
        router = _router;
    }

    //Buy SHEEP with gasToken earned from rent paid
    function buySheep() public {

        uint256 balGasToken = IERC20(wGasToken).balanceOf(address(this));
        uint teamFee = balGasToken * 5 / 100;
        uint buyAmount = balGasToken - teamFee;

        IERC20(wGasToken).transfer(ISheep(sheep).owner(), teamFee);
        
        IERC20(wGasToken).approve(router,buyAmount);

        uint256 sheepBefore = totalSheepBalance();
        IRouter(router).swapExactTokensForTokensSimple(buyAmount, 1e18, wGasToken, sheep, false, address(this), block.timestamp + 10);
        uint256 sheepAfter = totalSheepBalance();

        uint256 sheepBuyBack = sheepAfter - sheepBefore;

        uint256 callerFee =  sheepBuyBack / 100;

        totalSheep += sheepBuyBack - callerFee;

        IERC20(sheep).transfer(msg.sender, callerFee);
    }

    // Deposit function for sheep with the SheepDog. You will pay x wGasTokens / day
    function protect(uint256 _amount) public nonReentrant{
        require(wenToClaim[msg.sender] == 0,"dog is going to sleep");
        require(_amount !=0, "amount == 0");
        require(sheepDogShares[msg.sender] + _amount <= 40000 * ONE,"to many sheep in one address");

        if (totalShares == 0 || totalSheep == 0) {
            require(_amount == 100e18,"To small first deposit");
            sheepDogShares[msg.sender] += _amount;
            totalShares += _amount;
        } else {
            uint256 what = _amount * (totalShares) / (totalSheep);
            require(what != 0, "deppsit to small");
            sheepDogShares[msg.sender] += what;
            totalShares += what;
        }
        ISheep(sheep).transferFrom(msg.sender, address(this), _amount);
        totalSheep += _amount;
        if (rentStart[msg.sender] == 0){
            rentStart[msg.sender] = block.timestamp;
        }
    }

    // Put your sheepDog to sleep so you can withdraw the sheep.
    function dogSleep() public {
        require(wenToClaim[msg.sender] == 0 || wenToClaim[msg.sender] + 172800 < block.timestamp,"dog is going to sleep");
        require(sheepDogShares[msg.sender] != 0,"no sheeps");

        wenToClaim[msg.sender] = block.timestamp + 172800; // 2 days
    }
    // Get your sheep back. User will need to pay 10 wGasTokens / day since when they deposited. 
    // 5% ove these are sent to team, and 95% accumulate here for buySheep()
    function getSheep() public {
        require(wenToClaim[msg.sender] != 0, "put dog to sleep fist");
        require(block.timestamp >= wenToClaim[msg.sender], "your sheepDog is not asleep yet");
        require(wenToClaim[msg.sender] + 172800 > block.timestamp, "sheepDog wake up again");

        uint256 what = sheepDogShares[msg.sender] * (totalSheep) / (totalShares);

        ISheep(sheep).transfer(msg.sender, what);
        totalSheep -= what;
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
        uint256 _calcRent = (block.timestamp - rentStart[_user]) / 86400 * TEN;
        return _calcRent;
    }

    function totalSheepBalance() public view returns (uint256) {
        return IERC20(sheep).balanceOf(address(this));
    }
}