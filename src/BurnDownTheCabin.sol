// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract BurnDownTheCabin is Ownable {


    address public sheppard; //this is the address of who made the LP
    address public cabin; //this is the LP token
    address public kindling; //this is the donation token
    uint256 public pyre; //this is the amount of donation required
    uint256 public woodpile; //this is the amount of donation already given
    uint256 public water; //this is the cooldown start time for rescuing the LP tokens

    bool public collectingWater; //this starts the cooldown on retrieveing the LPs
    bool public built; //used for init
    uint256 public immutable ONE_WEEK = 604800; //this is the delay on retrieving the LPs

    event cabinBurntDown(address arsonist);
    event sheppardSavingCabin();
    event sheppardSavedCabin();

    function buildTheCabin(address _cabin, address _kindling, uint256 _pyre, address _sheppard) public onlyOwner {
        require(!built);
        cabin = _cabin;
        kindling = _kindling;
        pyre = _pyre;
        sheppard = _sheppard;
    }

    function addToWoodPile(uint256 _logs) public {
        require (IERC20(cabin).balanceOf(address(this)) > 0, 'cabin is already burnt down');
        IERC20(kindling).transferFrom(msg.sender, sheppard, _logs);
        woodpile = woodpile + _logs;
    }

    function burnTheCabin() public {
        require (woodpile >= pyre, 'there arent enough logs yet');
        uint256 cabinSize = IERC20(cabin).balanceOf(address(this));
        IERC20(cabin).transfer(0x000000000000000000000000000000000000dEaD, cabinSize);
        emit cabinBurntDown(msg.sender);
    }

    function collectWater() public onlyOwner {
        water = block.timestamp;
        collectingWater = true;
    }

    function saveTheCabin() public onlyOwner {
        require (water + ONE_WEEK < block.timestamp, 'sheppard, you dont have enough water');
        require (collectingWater == true, 'sheppard, you didnt even start collecting water');
        uint256 cabinSize = IERC20(cabin).balanceOf(address(this));
        IERC20(cabin).transfer(sheppard, cabinSize);

        emit sheppardSavedCabin();
    }


}