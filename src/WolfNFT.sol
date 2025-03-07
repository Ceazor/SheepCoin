// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "src/interfaces/ISheep.sol";
import "src/interfaces/IPair.sol";

// This contract gets to burn SHEEP token in other addresses
// It costs x gasTokens and SHEEP to mint
// It gets hungrier and starves

contract WOLF is ERC721Enumerable, Ownable2Step {
    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;
    uint256 public constant DAY = 86400;
    uint256 public constant WEEK = 604800;

    address public sheep;
    uint256 public mating = ONE;
    mapping(uint256 => uint256) public starved; //tokenId => time
    mapping(uint256 => uint256) public hungry; //tokenId => time
    mapping(uint256 => uint256) public hunger; //tokenId => quantity will eat
    mapping(uint256 => uint256) public eatenFromMarket; //tokenId => how many eaten
    mapping(address => uint256) public mints; //owner => tokenId
    uint256 wolfID = 0;

    address public wGasToken;
    address public sheepDog;
    address public sheepMarket;


    mapping(address => bool) public canNotBeEaten;

    event cryWolf(address indexed minter, uint256 amount);
    event sheepEaten(address indexed victim, uint256 amount);

    // Static URI for all tokens - Image does not vary
    string private _staticTokenURI;

    constructor(address _sheep, address _sheepDog,address _sheepMarket ) ERC721 ("Wolf", "WOLF") {
        sheep = _sheep;
        wGasToken = ISheep(sheep).wGasToken();
        sheepDog = _sheepDog;
        canNotBeEaten[sheepDog] = true;
        sheepMarket = _sheepMarket;
    }

    // This function allows caller to pay fee, burn tokens, and mint an NFT
    // The fee is in wGasTokens
    // The burned tokens are SHEEP - User must have bal
    function getWolf() public {
        ISheep(sheep).eatSheep(msg.sender, mating, address(this),0);
        emit sheepEaten(msg.sender, mating);

        mating = mating + ONE;

        IERC20(wGasToken).transferFrom(msg.sender, sheepDog, HUNDRED); // TODO decide the price 

        _safeMint(msg.sender, wolfID);
        emit cryWolf(msg.sender, wolfID);

        starved[wolfID] = block.timestamp + WEEK;
        hungry[wolfID] = block.timestamp + DAY;
        hunger[wolfID] = ONE;

        wolfID = wolfID + 1;
    }

    // Owner of wolfNFT calls this to burn SHEEP
    // Must burn 1/wk can 1/day

    function eatSheep(address _victim, uint256 _wolfID) public {
        require(_isApprovedOrOwner(msg.sender, _wolfID), "you dont own this wolf");
        require(block.timestamp < starved[_wolfID], 'your wolf starved');
        require(block.timestamp > hungry[_wolfID], "your wolf is not hungry yet");
        require(eatenFromMarket[_wolfID] <= 2 || _victim != sheepMarket,"you eat too much from the market");
        uint256 sheepToEat = hunger[_wolfID];

        _burnSheep(_victim, sheepToEat);

        hunger[_wolfID] = hunger[_wolfID] + ONE;
        hungry[_wolfID] = block.timestamp + DAY; // 1 day
        starved[_wolfID] = block.timestamp + WEEK; // 1 week

        if( _victim == sheepMarket) {
            eatenFromMarket[_wolfID] += 1;
        } else {
            eatenFromMarket[_wolfID] = 0;
        }

        emit sheepEaten(_victim, sheepToEat);
    }

    // internal function that actually burns
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

    // Returns the static URI for all tokens
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _staticTokenURI;
    }

    // Sets a new static URI (onlyOwner)
    function setTokenURI(string memory newURI) public onlyOwner {
        _staticTokenURI = newURI;
    }

    ///////////////////////////////////////
    /////OWNER FUNCTIONS/////////////////
    ///////////////////////////////////////

    function toggleCanBeEaten(address _victim) public onlyOwner {
        canNotBeEaten[_victim] = !canNotBeEaten[_victim];
    }

}