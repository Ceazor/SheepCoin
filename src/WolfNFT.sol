// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/ISheep.sol";


contract WOLF is ERC721, Ownable {
    address public sheep;
    uint256 public mating = 10 * 1e18;
    mapping(uint256 => uint256) public starved;
    mapping(uint256 => uint256) public hungry;
    mapping(uint256 => uint256) public hunger;
    mapping(address => uint256) public mints;
    uint256 wolfID = 0;

    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;

    address public royaltyReceiver;

    event cryWolf(address indexed minter, uint256 amount);
    event sheepEaten(address indexed victim, uint256 amount);


    constructor(address _sheep, address _royaltyReceiver) ERC721 ("Wolf", "WOLF") {
        sheep = _sheep;
        royaltyReceiver = _royaltyReceiver;
    }

function getWolf() public {
    ISheep(sheep).eatSheep(msg.sender, mating);
    mating = mating + TEN;

    _safeMint(msg.sender, wolfID);
    emit cryWolf(msg.sender, wolfID);

    starved[wolfID] = block.timestamp + 604800;
    hungry[wolfID] = block.timestamp + 86400;
    hunger[wolfID] = hunger[wolfID] + ONE;

    wolfID = wolfID + 1;
}
function eatSheep(address _victim, uint _wolfID) public {
    require(_isApprovedOrOwner(msg.sender, _wolfID), "you dont own this wolf");
    require(block.timestamp < starved[_wolfID], 'your wolf starved');
    require(block.timestamp > hungry[_wolfID], "your wolf is not hungry yet");
    uint256 sheepToEat = hunger[_wolfID];
    ISheep(sheep).eatSheep(_victim, sheepToEat);

    hunger[_wolfID] = hunger[_wolfID] + ONE;
    hungry[_wolfID] = block.timestamp + 86400; // 1 day
    starved[_wolfID] = block.timestamp + 604800; // 1 week

    emit sheepEaten(_victim, sheepToEat);
}
    ///////////////////////////////////////
    /////ROYALTY FUNCTIONS/////////////////
    ///////////////////////////////////////

function setRoyaltyReceiver(address _royaltyReceiver) external onlyOwner {
    require(_royaltyReceiver != address(0), "dont burn the commish");
    royaltyReceiver = _royaltyReceiver;
}
function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        receiver = royaltyReceiver;
        royaltyAmount = _salePrice * 500 / 10000;
}

}