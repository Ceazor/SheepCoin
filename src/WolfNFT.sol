// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/interfaces/ISheep.sol";
import "src/interfaces/IPair.sol";


contract WOLF is ERC721, Ownable {
    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;

    address public sheep;
    uint256 public mating = ONE;
    mapping(uint256 => uint256) public starved; //tokenId => time
    mapping(uint256 => uint256) public hungry; //tokenId => time
    mapping(uint256 => uint256) public hunger; //tokenId => quantity will eat
    mapping(address => uint256) public mints; //owner => tokenId
    uint256 wolfID = 0;

    address public wGasToken;
    address public sheepDog;
    address public sheepMarket;


    mapping(address => bool) public canNotBeEaten;

    event cryWolf(address indexed minter, uint256 amount);
    event sheepEaten(address indexed victim, uint256 amount);


    constructor(address _sheep, address _sheepDog,address _sheepMarket) ERC721 ("Wolf", "WOLF") {
        sheep = _sheep;
        wGasToken = ISheep(sheep).wGasToken();
        sheepDog = _sheepDog;
        canNotBeEaten[sheepDog] = true;
        sheepMarket = _sheepMarket;
    }

    function getWolf() public {
        ISheep(sheep).eatSheep(msg.sender, mating, address(this),0);
        emit sheepEaten(msg.sender, mating);

        mating = mating + ONE;

        IERC20(wGasToken).transferFrom(msg.sender, sheepDog, HUNDRED); // TODO decide the price 

        _safeMint(msg.sender, wolfID);
        emit cryWolf(msg.sender, wolfID);

        starved[wolfID] = block.timestamp + 604800;
        hungry[wolfID] = block.timestamp + 86400;
        hunger[wolfID] = hunger[wolfID] + ONE;

        wolfID = wolfID + 1;
    }

    function eatSheep(address _victim, uint256 _wolfID) public {
        require(_isApprovedOrOwner(msg.sender, _wolfID), "you dont own this wolf");
        require(block.timestamp < starved[_wolfID], 'your wolf starved');
        require(block.timestamp > hungry[_wolfID], "your wolf is not hungry yet");
        uint256 sheepToEat = hunger[_wolfID];

        _burnSheep(_victim, sheepToEat);

        hunger[_wolfID] = hunger[_wolfID] + ONE;
        hungry[_wolfID] = block.timestamp + 86400; // 1 day
        starved[_wolfID] = block.timestamp + 604800; // 1 week

        emit sheepEaten(_victim, sheepToEat);
    }

    function _burnSheep(address _victim,uint256 _sheepToEat) private {
        require(!canNotBeEaten[_victim],"can not eat from this address");

        uint256 mintPercent = 25;
        bool isSheepMarket = _victim == sheepMarket;

        if(isSheepMarket) {
            mintPercent = 0;
        }

        ISheep(sheep).eatSheep(_victim, _sheepToEat, msg.sender,mintPercent);

        if(isSheepMarket) {
            IPair(sheepMarket).sync();
        }
    }

    ///////////////////////////////////////
    /////ROYALTY FUNCTIONS/////////////////
    ///////////////////////////////////////

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (
            address receiver,
            uint256 royaltyAmount
        ) {
            receiver = ISheep(sheep).owner();
            royaltyAmount = _salePrice * 500 / 10000;
    }

    ///////////////////////////////////////
    /////OWNER FUNCTIONS/////////////////
    ///////////////////////////////////////

    function toggleCanBeEaten(address _victim) public onlyOwner {
        canNotBeEaten[_victim] = !canNotBeEaten[_victim];
    }

}