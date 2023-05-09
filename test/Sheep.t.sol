// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Sheep.sol";

contract SheepTest is Test {
    SHEEP public sheep;
    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;

    function setUp() public {
        sheep = new SHEEP();
    }

    function testTotalSuppy() public {
        uint256 tSupply = sheep.totalSupply();
        assertEq(tSupply, 1_000_000 * 1e18);
    }

    function testBalanceThis() public view returns (uint256){
        uint256 bal = sheep.balanceOf(address(this));
        return bal;

    }

    function testTransferBeforePasture() public {
        uint sendSheep = 1 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        testBalanceThis();
        assertEq(sheep.balanceOf(ceazor), 1 * 1e18);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }

    function testTransferAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = 1 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        testBalanceThis();
        assertEq(sheep.balanceOf(ceazor), 1 * 1e18);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }

    function testFailTransferTooMuchAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        testBalanceThis();
        assertEq(sheep.balanceOf(ceazor), 1 * 1e18);
        assertEq(sheep.balanceOf(address(this)), sheep.totalSupply() - sendSheep);
    }
        
    function testTransfer2TimesAfterPasture() public {
        sheep.takeToPasture();
        uint sendSheep = 1 * 1e18;
        uint send2Sheep = 2 * 1e18;
        sheep.transfer(ceazor, sendSheep);
        sheep.transfer(dan, send2Sheep);
        testBalanceThis();
        assertEq(sheep.balanceOf(ceazor), 1 * 1e18);
        assertEq(sheep.balanceOf(dan), 2 * 1e18);
    }

    function testFailReturnSheep() public {
        sheep.takeToPasture();
        uint sendSheep = 1 * 1e18;
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
        uint sendSheep = 1 * 1e18;
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

}
