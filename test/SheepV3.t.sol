// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SheepV3.sol";
import "../src/WolfNFT.sol";
import "../src/sheepDog.sol";
import "../src/gasToken.sol";
import "../src/sheepBreeder.sol";
import "../src/fakeRouter.sol";

contract SheepTest is Test {
    SHEEP public sheep;
    WOLF public wolf;
    SHEEPDOG public sheepDog;
    wGAS public wGasToken;
    SHEEPBREEDER public breeder;
    FAKEROUTER public router;

    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;
    address constant pair = 0x699675204aFD7Ac2BB146d60e4E3Ddc243843519;
    address constant trainer = 0x06b16991B53632C2362267579AE7C4863c72fDb8;
    address constant pol = 0x06b16991B53632C2362267579AE7C4863c72fDb8;

    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;

    function setUp() public {
        wGasToken = new wGAS();
            sheep = new SHEEP(address(wGasToken),pol);
        
        
        router = new FAKEROUTER();

            breeder = new SHEEPBREEDER(address(sheep), address(wGasToken), address(router));
            sheepDog = new SHEEPDOG(address(sheep));
            wolf = new WOLF(address(sheep), address(sheepDog),pair);

        
        sheep.buildTheFarm(address(wolf)); //TO:DO.. change these when ready

        wGasToken.transfer(ceazor, HUNDRED * 2);
        wGasToken.transfer(dan, HUNDRED * 2);
    }

    function balanceThis() public view returns (uint256){
        uint256 bal = sheep.balanceOf(address(this));
        return bal;
    }

    function testMintForFee() public {
        uint ownerPreBalance = wGasToken.balanceOf(address(this));

        vm.startPrank(ceazor);
        
        wGasToken.approve(address(sheep), 10e18);
        sheep.mintForFee(10e18);

        assertEq(sheep.balanceOf(ceazor), ONE * 10);
        assertEq(sheep.balanceOf(pol), 975e16);

        assertEq(wGasToken.balanceOf(pol), 975e16);
        assertEq(wGasToken.balanceOf(address(this)) - ownerPreBalance, 25e16);


        vm.stopPrank();
    }

    function testTransferBeforePasture() public {
        uint sendSheep = ONE;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - (sendSheep + HUNDRED + HUNDRED));
    }

    function testTransferAfterPasture() public {
        sheep.takeOutOfPasture();
        uint sendSheep = ONE;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - (sendSheep + HUNDRED + HUNDRED));
    }

    function testFailTransferTooMuchAfterPasture() public {
        sheep.takeOutOfPasture();
        uint sendSheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - (sendSheep + HUNDRED + HUNDRED));
    }
        
    function testTransfer2TimesAfterPasture() public {
        sheep.takeOutOfPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(dan), 2 * 1e18);
    }

    function testSellingToZero() public {
        sheep.takeOutOfPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        uint send3Sheep = 3 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        sheep.transfer(pair, send3Sheep);
        vm.prank(pair);
        sheep.transfer(dan, send2Sheep);
        vm.prank(pair);
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
        sheep.takeOutOfPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2  * 1e18;
        uint send3Sheep = 3 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        sheep.transfer(ceazor, send3Sheep);
        vm.warp(604801);
        vm.prank(dan);
        sheep.transfer(address(this), send2Sheep);
        vm.prank(ceazor);
        sheep.transfer(address(this), send3Sheep);
    }

    function testMintWolves() public {
        uint sendSheep = HUNDRED;
        sheep.transfer(ceazor, sendSheep);
        vm.startPrank(ceazor);
        sheep.approve(address(wolf), HUNDRED);
        wGasToken.approve(address(wolf), HUNDRED + HUNDRED);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == sendSheep - ONE);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == sendSheep - ONE - ONE - ONE);
    }

    function testWolfEatTwice() public {
        uint sendSheep = ONE;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
            wGasToken.approve(address(wolf), HUNDRED);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == sendSheepDan - ONE);
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == sendSheepDan - (ONE + ONE + ONE));
            assert(sheep.balanceOf(ceazor) == (ONE + ONE + ONE) * 25 /100);
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
        vm.startPrank(pair);
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
        sheep.transfer(dan, HUNDRED);
        vm.startPrank(dan);
            sheep.approve(address(sheepDog), HUNDRED);
            sheepDog.protect(HUNDRED);
            uint256 danBal = sheepDog.sheepDogShares(dan);
            assert(sheep.balanceOf(dan) == 0);
            assert(sheepDog.sheepDogShares(dan) == HUNDRED);
            sheepDog.dogSleep(danBal);
            vm.warp(block.timestamp + 172800);
            uint256 rent = sheepDog.getCurrentRent(dan);
            wGasToken.approve(address(sheepDog), rent);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == HUNDRED);
            assert(wGasToken.balanceOf(trainer) == rent * 5 / 100);
            assert(wGasToken.balanceOf(address(breeder)) == rent * 95 / 100);

    }
    function testLeaveSheepDogMulti() public {
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(address(sheepDog), TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan) == 0);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172800);
            uint256 rentAmt = sheepDog.getCurrentRent(dan);
            wGasToken.approve(address(sheepDog), rentAmt);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == ONE);
            assert(wGasToken.balanceOf(trainer) == rentAmt * 5 / 100);
            assert(wGasToken.balanceOf(address(breeder)) == rentAmt * 95 / 100);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172800);
            uint256 rentAmt2 = sheepDog.getCurrentRent(dan);
            wGasToken.approve(address(sheepDog), rentAmt2);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == ONE + ONE);
            assert(wGasToken.balanceOf(trainer) == (rentAmt + rentAmt2) * 5 / 100);
            assert(wGasToken.balanceOf(address(breeder)) == (rentAmt + rentAmt2) * 95 / 100);

    }
    function testFailLeaveSheepDogEarly() public {
        sheep.transfer(ceazor, TEN);
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(address(sheepDog), TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan) == 0);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172600);
            sheepDog.getSheep();
    }
    // function testSheepDogNoReduceHerdsize() public {
    //     sheep.takeToPasture();
    //     sheep.transfer(ceazor, ONE);
    //     sheep.transfer(dan, ONE + ONE);
    //     sheep.transfer(pair, ONE + ONE + ONE);
    //     vm.startPrank(pair);
    //         uint256 pairBal = sheep.balanceOf(pair);
    //         sheep.approve(address(sheepDog), pairBal);
    //         sheepDog.protect(pairBal);
    //         assert(sheep.balanceOf(pair) == 0);
    //         assert(sheep.herdSize() == 4); 

    // }
    // function testSheepDogExemptFromHerdSize() public {
    //     sheep.takeToPasture();
    //     sheep.transfer(ceazor, ONE);
    //     sheep.transfer(dan, ONE + ONE);
    //     sheep.transfer(dan, ONE + ONE);
    //     sheep.transfer(dan, ONE + ONE);
    //     assert(sheep.herdSize() == 3);
    //     vm.startPrank(dan);
    //         uint256 danBal = sheep.balanceOf(dan);
    //         sheep.approve(address(sheepDog), danBal);
    //         sheepDog.protect(danBal); //allowed to send more than herdSize to sheepDog
    //         assert(sheep.balanceOf(dan) == 0);
    //         assert(sheep.herdSize() == 3); 
    //             uint256 danDogBal = sheepDog.balanceOf(dan);
    //             sheepDog.dogSleep(danDogBal);
    //             vm.warp(block.timestamp + 172800);
    //             uint256 rentAmt = sheepDog.getCurrentRent(dan);
    //             wGasToken.approve(address(sheepDog), rentAmt);
    //             sheepDog.getSheep(); //sheepDog is exempt from herdSize
    // }
    function testSwapViaRouter() public {
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
    function testBreeder() public {
        sheep.takeOutOfPasture();
        sheep.transfer(address(router), HUNDRED + HUNDRED);

        uint sendSheep = HUNDRED;
        sheep.transfer(ceazor, sendSheep);
        vm.startPrank(ceazor);
            sheep.approve(address(wolf), HUNDRED);
            wGasToken.approve(address(wolf), HUNDRED + HUNDRED);
            wolf.getWolf();
            assert(wGasToken.balanceOf(address(breeder)) == HUNDRED);
            IERC20(sheep).approve(address(breeder), ONE + ONE);
            breeder.breed();
            assert(wGasToken.balanceOf(address(breeder)) == 0);
            sheep.balanceOf(address(breeder));

            vm.warp(block.timestamp + 172800);
            breeder.getSheep();
            assert(sheep.balanceOf(address(breeder)) == (TEN - ONE));

    }

}
