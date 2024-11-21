// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



pragma solidity ^0.8.13;

contract SHEEPDOG is ERC20, Ownable, ReentrancyGuard{
    IERC20 public sheep;
    mapping(address => uint256) public sheepToClaim;
    mapping(address => uint256) public wenToClaim;
    mapping(address => uint256) public rentStart;
    address public trainer;
    address public wGasToken;
    address public mater;

    constructor(
        address _trainer,
        address _wGasToken,
        address _mater,
        IERC20 _sheep,
        string memory _name,
        string memory _symbol) ERC20 (
         string(_name),
         string(_symbol) 
        ) {
        sheep = _sheep;
        trainer = _trainer;
        wGasToken = _wGasToken;
        mater = _mater;
    }

    // Project your sheep with a SheepDog. But you have to pay 1% to the trainer
    function protect(uint256 _amount) public nonReentrant{
        uint256 totalsheep = sheep.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalsheep == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 what = _amount * (totalShares) / (totalsheep);
            _mint(msg.sender, what);
        }
        sheep.transferFrom(msg.sender, address(this), _amount);
        if (rentStart[msg.sender] == 0){
            rentStart[msg.sender] = block.timestamp;
            }

    }

    // Put your sheepDog to sleep so you can move the sheep.
    function dogSleep(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what = _share * (sheep.balanceOf(address(this))) / (totalShares);
        _burn(msg.sender, _share);
        sheepToClaim[msg.sender] = what;
        wenToClaim[msg.sender] = block.timestamp + 172800; // 2 days
    }
    // Get your sheep back. User will need to pay 10 wGasTokens / day since they deposited. 5% ove these are sent to team, and 95% are sent to the Mater
    function getSheep() public {
        require(block.timestamp >= wenToClaim[msg.sender], "your sheepDog is not asleep yet");
        uint256 sheepAmt = sheepToClaim[msg.sender]; 
        sheep.transfer(msg.sender, sheepAmt);
        uint256 payRent = getCurrentRent(msg.sender);
        uint256 teamCutOfRent = payRent * 5 / 100;
        uint256 rentToMater = payRent - teamCutOfRent;
        IERC20(wGasToken).transferFrom(msg.sender, trainer, teamCutOfRent);
        IERC20(wGasToken).transferFrom(msg.sender, mater, rentToMater);

        rentStart[msg.sender] = 0;
    }
    ///////////////////////////////////////////////
    /////////READ FUNCTIONS////////////////////////
    ///////////////////////////////////////////////

    function getCurrentRent(address _user) public view returns (uint256 _currentRent) {
        uint256 _calcRent = (block.timestamp - rentStart[_user]) / 86400 * 10;
        return _calcRent;
    }
}