// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SheepV3.sol";
import "../src/WolfNFT.sol";
import "../src/sheepDog.sol";

contract SheepTest is Test {
    SHEEP public sheep;
    WOLF public wolf;
    SHEEPDOG public sheepDog;
    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;
    address constant dumper = 0x699675204aFD7Ac2BB146d60e4E3Ddc243843519;
    address constant sheepAddy = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;
    address constant wolfAddy = 0x2e234DAe75C793f67A35089C9d99245E1C58470b;
    address constant sheepDogAddy = 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a;
    address constant sheppard = 0x06b16991B53632C2362267579AE7C4863c72fDb8;

    uint256 public constant ONE = 1 * 1e18;
    uint256 public constant TEN = 10 * 1e18;
    uint256 public constant HUNDRED = 100 * 1e18;

    function setUp() public {
        sheep = new SHEEP();
        wolf = new WOLF(sheepAddy, ceazor);
        sheepDog = new SHEEPDOG(sheppard, sheep, "SheepDog", "sheepDOG");
        sheep.buildTheFarm(wolfAddy, sheepDogAddy, dumper); //TO:DO.. change these when ready
    }

    function balanceThis() public view returns (uint256){
        uint256 bal = sheep.balanceOf(address(this));
        return bal;
    }

    function testTransferBeforePasture() public {
        uint sendSheep = ONE;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }

    function testTransferAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = ONE;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }

    function testFailTransferTooMuchAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }
        
    function testTransfer2TimesAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        balanceThis();
        assertEq(sheep.balanceOf(ceazor), ONE);
        assertEq(sheep.balanceOf(dan), 2 * 1e18);
    }

    function testSellingToZero() public {
        sheep.takeToPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2 * 1e18;
        uint send3Sheep = 3 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        sheep.transfer(dumper, send3Sheep);
        assertEq(sheep.herdSize(), 4);
        vm.prank(dumper);
        sheep.transfer(dan, send2Sheep);
        assertEq(sheep.herdSize(), 4);
        vm.prank(dumper);
        sheep.transfer(dan, sendSheep);
        assertEq(sheep.herdSize(), 3);
    }

    function testFailReturnSheepToContract() public {
        sheep.takeToPasture();
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
        sheep.takeToPasture();
        uint sendSheep = ONE;
        uint send2Sheep = 2  * 1e18;
        uint send3Sheep = 3 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        sheep.transfer(ceazor, send3Sheep);
        sheep.releaseLassie();
        vm.warp(604801);
        sheep.penTheSheep();
        vm.prank(dan);
        sheep.transfer(address(this), send2Sheep);
        vm.prank(ceazor);
        sheep.transfer(address(this), send3Sheep);
    }

    function testMintWolves() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        vm.startPrank(ceazor);
        sheep.approve(wolfAddy, 10000000 * 1e18);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == sendSheep - ONE);
        wolf.getWolf();
        assert(sheep.balanceOf(ceazor) == sendSheep - ONE - ONE - ONE);
    }

    function testWolvesEat() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
            sheep.approve(wolfAddy, 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == sendSheepDan - ONE);
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(dan, 0);
            assert(sheep.balanceOf(dan) == sendSheepDan - (ONE + ONE + ONE));
    }

    function testFailWolvesEatEarly() public {
        uint sendSheep = TEN + TEN + TEN;
        sheep.transfer(ceazor, sendSheep);
        uint sendSheepDan = TEN;
        sheep.transfer(dan, sendSheepDan);        
        vm.startPrank(ceazor);
        sheep.approve(wolfAddy, 10000000 * 1e18);
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
            sheep.approve(wolfAddy, 10000000 * 1e18);
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
            sheep.approve(wolfAddy, 10000000 * 1e18);
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
            sheep.approve(sheepDogAddy, TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan)== 0);
            assert(sheep.balanceOf(sheepDogAddy) == TEN);
            assert(sheepDog.balanceOf(dan) == TEN);
        vm.stopPrank();
        vm.startPrank(ceazor);
            sheep.approve(wolfAddy, 10000000 * 1e18);
            wolf.getWolf();
            vm.warp(block.timestamp + 86401);
            wolf.eatSheep(sheepDogAddy, 0);
    }    
    function testLeaveSheepDogAll() public {
        sheep.transfer(dan, HUNDRED);
        vm.startPrank(dan);
            sheep.approve(sheepDogAddy, HUNDRED);
            sheepDog.protect(HUNDRED);
            uint256 danBal = sheepDog.balanceOf(dan);
            assert(sheep.balanceOf(dan) == 0);
            assert(sheepDog.balanceOf(dan) == HUNDRED - ONE);
            sheepDog.dogSleep(danBal);
            vm.warp(block.timestamp + 172800);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == HUNDRED - ONE);
            assert(sheep.balanceOf(sheppard) == ONE);

    }
    function testLeaveSheepDogMulti() public {
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(sheepDogAddy, TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan) == 0);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172800);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == ONE);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172800);
            sheepDog.getSheep();
            assert(sheep.balanceOf(dan) == ONE + ONE);
    }
    function testFailLeaveSheepDogEarly() public {
        sheep.transfer(ceazor, TEN);
        sheep.transfer(dan, TEN);
        vm.startPrank(dan);
            sheep.approve(sheepDogAddy, TEN);
            sheepDog.protect(TEN);
            assert(sheep.balanceOf(dan) == 0);
            sheepDog.dogSleep(ONE);
            vm.warp(block.timestamp + 172600);
            sheepDog.getSheep();
    }
    function testSheepDogNoReduceHerdsize() public {
        sheep.takeToPasture();
        sheep.transfer(ceazor, ONE);
        sheep.transfer(dan, ONE + ONE);
        sheep.transfer(dumper, ONE + ONE + ONE);
        assert(sheep.herdSize() == 4);
        vm.startPrank(dumper);
            uint256 dumperBal = sheep.balanceOf(dumper);
            sheep.approve(sheepDogAddy, dumperBal);
            sheepDog.protect(dumperBal);
            assert(sheep.balanceOf(dumper) == 0);
            assert(sheep.herdSize() == 5); //this increased not cause sheepDog, but fee to Sheppard

    }
    function testSheepDogExemptFromHerdSize() public {
        sheep.takeToPasture();
        sheep.transfer(ceazor, ONE);
        sheep.transfer(dan, ONE + ONE);
        sheep.transfer(dan, ONE + ONE);
        sheep.transfer(dan, ONE + ONE);
        assert(sheep.herdSize() == 3);
        vm.startPrank(dan);
            uint256 danBal = sheep.balanceOf(dan);
            sheep.approve(sheepDogAddy, danBal);
            sheepDog.protect(ONE + ONE);
            sheepDog.protect(ONE + ONE);
            sheepDog.protect(ONE + ONE);
            assert(sheep.balanceOf(dan) == 0);
            assert(sheep.herdSize() == 4); //this increased not cause sheepDog, but fee to Sheppard
                uint256 danDogBal = sheepDog.balanceOf(dan);
                sheepDog.dogSleep(danDogBal);
                vm.warp(block.timestamp + 172800);
                sheepDog.getSheep(); //sheepDog is exempt from herdSize


    }

}
