// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SheepV3.sol";
import "../src/WolfNFT.sol";
import "../src/sheepDog.sol";
import "../src/gasToken.sol";
import "../src/fakeRouter.sol";
import "../src/fakePair.sol";


contract SheepTest is Test {
    SHEEP public sheep;
    WOLF public wolf;
    SHEEPDOG public sheepDog;
    wGAS public wGasToken;
    FAKEROUTER public router;
    FAKEPAIR public pair;

    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;
    address constant trainer = 0x06b16991B53632C2362267579AE7C4863c72fDb8;
    address constant pol = 0x06b16991B53632C2362267579AE7C4863c72fDb8;

    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;

    function setUp() public {
        wGasToken = new wGAS();
        sheep = new SHEEP(address(wGasToken),pol);
        router = new FAKEROUTER();
        pair = new FAKEPAIR(address(sheep),address(wGasToken));


        sheepDog = new SHEEPDOG(address(sheep),address(router));
        wolf = new WOLF(address(sheep), address(sheepDog),address(pair));

        sheep.buildTheFarm(address(wolf)); //TO:DO.. change these when ready
        sheep.startSale();

        wGasToken.transfer(ceazor, HUNDRED * 200);
        wGasToken.transfer(dan, HUNDRED * 200);

        wGasToken.transfer(address(pair), HUNDRED);
        pair.sync();
    }

    function balanceThis() public view returns (uint256){
        uint256 bal = sheep.balanceOf(address(this));
        return bal;
    }

    function mintSheepPreMint(uint256 mint) public {
        wGasToken.approve(address(sheep), mint);
        sheep.mintForFee(mint);
    }

    function mintSheepForAddress(address to,uint mint) public {
        wGasToken.transfer(to, mint);

        vm.startPrank(to);
        mintSheepPreMint(mint);
        vm.stopPrank();
    }

    function testMintForFee() public {
        uint ownerPreBalance = wGasToken.balanceOf(address(this));

        vm.startPrank(ceazor);
        
        wGasToken.approve(address(sheep), 10e18);
        sheep.mintForFee(10e18);

        assertEq(sheep.balanceOf(ceazor), ONE * 10);
        assertEq(sheep.balanceOf(pol), 950e16);

        assertEq(wGasToken.balanceOf(pol), 950e16);
        assertEq(wGasToken.balanceOf(address(this)) - ownerPreBalance, 50e16);


        vm.stopPrank();
    }

    function testMintForFeeNative() public {
        uint ownerPreBalance = wGasToken.balanceOf(address(this));
        
        deal(address(ceazor), 10e18);

        vm.startPrank(ceazor);
        
        sheep.mintForFee{value:10e18}();

        assertEq(sheep.balanceOf(ceazor), ONE * 10);
        assertEq(sheep.balanceOf(pol), 950e16);

        assertEq(wGasToken.balanceOf(pol), 950e16);
        assertEq(wGasToken.balanceOf(address(this)) - ownerPreBalance, 50e16);


        vm.stopPrank();
    }

    function testMintForFeeMax() public {
        uint ownerPreBalance = wGasToken.balanceOf(address(this));

        wGasToken.transfer(ceazor, 2000001e18);

        vm.startPrank(ceazor);
        
        wGasToken.approve(address(sheep), 2000001e18);
        sheep.mintForFee(2000000e18);

        vm.expectRevert();

        sheep.mintForFee(1e18);

        vm.stopPrank();
    }

    function testTransferBeforePasture() public {
        uint sendSheep = ONE;

        vm.expectRevert();
        sheep.transfer(ceazor, sendSheep);
    }

    function testTransferAfterPasture() public {
        uint sendSheep = ONE;
        mintSheepForAddress(ceazor, sendSheep);
        sheep.takeOutOfPasture();

        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.totalSupply(),ONE + (ONE * 950/1000));
    }

    function testFailTransferTooMuchAfterPasture() public {
        uint sendSheep = 2 * 1e18;
        mintSheepForAddress(ceazor, sendSheep);
        sheep.takeOutOfPasture();

        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - (sendSheep + HUNDRED + HUNDRED));
    }
        
    function testTransfer2TimesAfterPasture() public {
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        mintSheepForAddress(ceazor, sendSheep);
        mintSheepForAddress(dan, send2Sheep);
        sheep.takeOutOfPasture();

        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(dan), 2 * 1e18);
    }

    function testSellingToZero() public {
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        uint send3Sheep = 3 * 1e18;
        mintSheepForAddress(ceazor, sendSheep);
        mintSheepForAddress(dan, send2Sheep);
        mintSheepForAddress(address(pair), HUNDRED);

        sheep.takeOutOfPasture();

        vm.prank(address(pair));
        sheep.transfer(dan, send2Sheep);
        vm.prank(address(pair));
        sheep.transfer(dan, sendSheep);
    }

    function testFailReturnSheepToContract() public {
        sheep.takeOutOfPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2  * 1e18;
        uint send3Sheep = 3 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        sheep.transfer(ceazor, send3Sheep);
        vm.prank(dan);
        sheep.transfer(address(this), send2Sheep);
        vm.prank(ceazor);
        sheep.transfer(address(this), send3Sheep);
    }

    function testReturnSheepAferLassie() public {
        uint sendSheep = ONE;
        uint send2Sheep = 2  * 1e18;
        uint send3Sheep = 3 * 1e18;
        mintSheepForAddress(ceazor, sendSheep);
        mintSheepForAddress(dan, send2Sheep);
        mintSheepForAddress(ceazor, send3Sheep);
    
        sheep.takeOutOfPasture();
   
        vm.warp(604801);
        vm.prank(dan);
        sheep.transfer(address(this), send2Sheep);
        vm.prank(ceazor);
        sheep.transfer(address(this), send3Sheep);
    }

    function testMintWolves() public {
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(ceazor);
        mintSheepPreMint(HUNDRED);
        vm.stopPrank();
        sheep.takeOutOfPasture();

        vm.startPrank(ceazor);
        sheep.approve(address(wolf), HUNDRED);
        wGasToken.approve(address(wolf), HUNDRED + HUNDRED);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == HUNDRED - ONE);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == HUNDRED - ONE - ONE - ONE);
    }

    function testWolfEatFromMarket() public {
        mintSheepForAddress(address(pair), HUNDRED);
        pair.sync();

        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(ceazor);
        mintSheepPreMint(ONE);
        vm.stopPrank();
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(dan);
        mintSheepPreMint(TEN);
        vm.stopPrank();
        sheep.takeOutOfPasture();
      
        vm.startPrank(ceazor);
        wGasToken.approve(address(wolf), HUNDRED);
        wolf.getWolf();
        vm.warp(block.timestamp + 86401);
        wolf.eatSheep(address(pair), 0);

        assert(sheep.balanceOf(address(pair)) == HUNDRED - ONE);
        assert(pair.reserve0() == HUNDRED - ONE);

        vm.warp(block.timestamp + 86401);
    }

    function testWolfEatFromMarketMoreThenLimit() public {
        mintSheepForAddress(address(pair), HUNDRED);
        pair.sync();

        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(ceazor);
        mintSheepPreMint(ONE);
        vm.stopPrank();
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(dan);
        mintSheepPreMint(TEN);
        vm.stopPrank();
        sheep.takeOutOfPasture();
      
        vm.startPrank(ceazor);
        wGasToken.approve(address(wolf), HUNDRED);
        wolf.getWolf();
        vm.warp(block.timestamp + 86401);

        for(int i=0;i< 3 ; i++) {
            wolf.eatSheep(address(pair), 0);
            vm.warp(block.timestamp + 86401);
        }


        vm.expectRevert();
        wolf.eatSheep(address(pair), 0);

        wolf.eatSheep(address(dan), 0);

        vm.warp(block.timestamp + 86401);

        wolf.eatSheep(address(pair), 0);

        assert(sheep.balanceOf(address(pair)) == 89e18);
        assert(pair.reserve0() == 89e18);

        vm.warp(block.timestamp + 86401);
    }

    function testWolfEatTwice() public {
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(ceazor);
        mintSheepPreMint(ONE);
        vm.stopPrank();
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(dan);
        mintSheepPreMint(TEN);
        vm.stopPrank();
        sheep.takeOutOfPasture();
      
        vm.startPrank(ceazor);
            wGasToken.approve(address(wolf), HUNDRED);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == TEN - ONE);
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == TEN - (ONE + ONE + ONE));
            assert(sheep.balanceOf(ceazor) == (ONE + ONE + ONE) * 25 /100);
    }

    function testWolfTryEatFromNoAllowedAddress() public {
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(ceazor);
        mintSheepPreMint(ONE);
        vm.stopPrank();
        wGasToken.transfer(ceazor, HUNDRED * 2);
        vm.startPrank(dan);
        mintSheepPreMint(TEN);
        vm.stopPrank();
        sheep.takeOutOfPasture();
        wolf.toggleCanBeEaten(dan);
      
        vm.startPrank(ceazor);
        wGasToken.approve(address(wolf), HUNDRED);
        wolf.getWolf();
        vm.warp(block.timestamp + 86401);
        vm.expectRevert();
        wolf.eatSheep(dan, 0);
    }

    function testFailOthersWolfEat() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
            sheep.approve(address(wolf), 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
        vm.stopPrank;
        vm.startPrank(address(pair));
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == sendSheepDan - ONE);
    }

    function testFailWolvesEatEarly() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
        sheep.approve(address(wolf), 10000000 * 1e18);
        wolf.getWolf();
        wolf.eatSheep(dan, 0);
        assert(sheep.balanceOf(dan) == sendSheepDan - ONE);
        wolf.eatSheep(dan, 0);
        assert(sheep.balanceOf(dan) == sendSheepDan - (ONE + ONE + ONE));
    }

    function testFailWolfStarve() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
            sheep.approve(address(wolf), 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 604801);
            wolf.eatSheep(dan, 0);
    }
    function testFailEatWithElsesWolf() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
            sheep.approve(address(wolf), 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 604801);
        vm.stopPrank();
        vm.startPrank(dan);
            wolf.eatSheep(ceazor, 0);
    }
    function testFailSheepDog() public {
        sheep.transfer(ceazor, TEN);
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(address(sheepDog), TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan)== 0);
            assert(sheep.balanceOf(address(sheepDog)) == TEN);
            assert(sheepDog.sheepDogShares(dan) == TEN);
        vm.stopPrank();
        vm.startPrank(ceazor);
            sheep.approve(address(wolf), 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(address(sheepDog), 0);
    }    
    function testLeaveSheepDogAll() public {
        vm.startPrank(dan);
        mintSheepPreMint(HUNDRED);
        vm.stopPrank();
        sheep.takeOutOfPasture();
        vm.startPrank(dan);
        sheep.approve(address(sheepDog), HUNDRED);
        sheepDog.protect(HUNDRED);
        uint256 danBal = sheepDog.sheepDogShares(dan);
        assert(sheep.balanceOf(dan) == 0);
        assert(sheepDog.sheepDogShares(dan) == HUNDRED);
        sheepDog.dogSleep();
        vm.warp(block.timestamp + 172800);
        uint256 rent = sheepDog.getCurrentRent(dan);
        wGasToken.approve(address(sheepDog), rent);
        sheepDog.getSheep();
        assert(sheep.balanceOf(dan) == HUNDRED);
        assert(wGasToken.balanceOf(address(sheepDog)) == rent);

    }

    function testPutToMuchToSheepDog() public {
        vm.startPrank(dan);
        mintSheepPreMint(HUNDRED * 41);
        vm.stopPrank();
        sheep.takeOutOfPasture();
        vm.startPrank(dan);
        sheep.approve(address(sheepDog), HUNDRED * 40);

        vm.expectRevert();
        sheepDog.protect(HUNDRED * 401);
    
    }

    function testLeaveSheepMoreThenNeeded() public {
        vm.startPrank(dan);
        mintSheepPreMint(HUNDRED);
        vm.stopPrank();
        sheep.takeOutOfPasture();
        vm.startPrank(dan);
        sheep.approve(address(sheepDog), HUNDRED);
        sheepDog.protect(HUNDRED);
        uint256 danBal = sheepDog.sheepDogShares(dan);
        assert(sheep.balanceOf(dan) == 0);
        assert(sheepDog.sheepDogShares(dan) == HUNDRED);
        sheepDog.dogSleep();
        vm.warp(block.timestamp + 172800 * 2 + 1);
        uint256 rent = sheepDog.getCurrentRent(dan);
        wGasToken.approve(address(sheepDog), rent);
        vm.expectRevert();
        sheepDog.getSheep();

        sheepDog.dogSleep();

        vm.warp(block.timestamp + 172800 + 1);
        
        rent = sheepDog.getCurrentRent(dan);
        wGasToken.approve(address(sheepDog), rent);
        sheepDog.getSheep();

        assert(sheep.balanceOf(dan) == HUNDRED);
        assert(wGasToken.balanceOf(address(sheepDog)) == rent);

    }

    function testLeaveSheepDogMulti() public {
        vm.startPrank(dan);
        mintSheepPreMint(TEN * 10);
        mintSheepForAddress(address(sheepDog), TEN);
        vm.stopPrank();
        sheep.takeOutOfPasture();
        vm.startPrank(dan);
        sheep.approve(address(sheepDog), TEN * 10);
        sheepDog.protect(TEN * 10);
        assert(sheep.balanceOf(dan) == 0);
        sheepDog.dogSleep();
        vm.warp(block.timestamp + 172800);
        uint256 rentAmt = sheepDog.getCurrentRent(dan);
        wGasToken.approve(address(sheepDog), rentAmt);
        sheepDog.getSheep();
        assert(sheep.balanceOf(dan) == TEN * 10);
        assert(wGasToken.balanceOf(address(sheepDog)) == rentAmt);

        vm.expectRevert();
        sheepDog.dogSleep();

    }

    function testFailLeaveSheepDogEarly() public {
        sheep.transfer(ceazor, TEN);
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(address(sheepDog), TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan) == 0);
            sheepDog.dogSleep();
            vm.warp(block.timestamp + 172600);
            sheepDog.getSheep();
    }
   
    function testSwapViaRouter() public {
        mintSheepForAddress(address(router), HUNDRED);
        sheep.takeOutOfPasture();
        vm.prank(dan);
            wGasToken.approve(address(router), HUNDRED);
        vm.stopPrank();
        vm.prank(dan);
            router.swapExactTokensForTokensSimple(
                TEN, 
                1, 
                address(wGasToken), 
                address(sheep), false, 
                dan, block.timestamp + 1);

    }
 

}
