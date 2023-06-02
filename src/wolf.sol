// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/interfaces/ISheep.sol";


contract WOLF is ERC20 {
    address public sheep;
    uint256 public mating = 10;
    mapping(address => uint256) public starved;
    mapping(address => uint256) public hungry;
    mapping(address => uint256) public hunger;

    uint256 public constant ONE = 1 * 1e18;


    constructor(address _sheep) ERC20("Wolf", "WOLF") {
        sheep = _sheep;
    }

function getWolf() public {
    require(IERC20(address(this)).balanceOf(msg.sender) == 0, "you already have a wolf");
    ISheep(sheep).transferFrom(msg.sender, address(this), mating);
    mating = mating + 10;
    
    _mint(msg.sender, ONE);
}
function eatSheep(address _victim) public {
    require(block.timestamp <= starved[msg.sender], 'your wolf starved');
    uint256 sheepToEat = hunger[msg.sender];
    ISheep(sheep).eatSheep(_victim, sheepToEat);

    hunger[msg.sender] = hunger[msg.sender] + 1;
    hungry[msg.sender] = block.timestamp + 86400;
    starved[msg.sender] = block.timestamp + 604800;
}

}