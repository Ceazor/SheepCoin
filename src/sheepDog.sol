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

    constructor(
        IERC20 _sheep,
        string memory _name,
        string memory _symbol) ERC20 (
         string(_name),
         string(_symbol)   
        ) {
        sheep = _sheep;
    }

    // Project your sheep with a SheepDog.
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
    }

    // Put your sheepDog to sleep so you can move the sheep.
    function dogSleep(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what = _share * (sheep.balanceOf(address(this))) / (totalShares);
        _burn(msg.sender, _share);
        sheepToClaim[msg.sender] = what;
        wenToClaim[msg.sender] = block.timestamp + 172800;
    }
    // Get your sheep back
    function getSheep() public {
        require(block.timestamp >= wenToClaim[msg.sender], "your sheepDog is not asleep yet");
        uint256 sheepAmt = sheepToClaim[msg.sender]; 
        sheep.transfer(msg.sender, sheepAmt);
    }
}