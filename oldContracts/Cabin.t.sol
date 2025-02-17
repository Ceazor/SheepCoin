// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Cabin.sol";

contract CabinTest is Test {
    CABIN public cabin;
    address constant LP = 0x48D26588dd4a236B12c848A85AEDf6613d4b51Ad;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    address cabinAddy = 0x43f46607d4136F1b134F28a23cA8CE795b29e3F3;

    address constant WETHWhale = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;
    address constant dep = 0x275946F183925c316feEB920F53562BBfC127134;


    uint256 arbFork;

    function setUp() public {
        arbFork = vm.createFork(vm.envString('ARB_RPC_URL'));

        vm.startPrank(dep);
            cabin = new CABIN();
            cabin.buildTheCabin(LP, WETH, 4 * 1e18, dep );
        vm.stopPrank();
    }

    function testFailDoubleInitCabin() public {
        vm.startPrank(dep);
            cabin.buildTheCabin(LP, WETH, 8 * 1e18, dep );
        vm.stopPrank();
    }

    function testDepositLP() public {  
        vm.startPrank(dep);      
            uint256 depBal = IERC20(LP).balanceOf(dep);
            IERC20(LP).approve(cabinAddy, depBal);
            cabin.sheppardGoHome(depBal);
            uint256 depBalAfter = IERC20(LP).balanceOf(dep);
            uint256 cabinBal = cabin.cabinBalance();
        vm.stopPrank();

        assert(depBalAfter == 0);
        assert(cabinBal == depBal);
    }

    function testBurnDownCabin() public {
        vm.startPrank(dep);      
            uint256 depBal = IERC20(LP).balanceOf(dep);
            IERC20(LP).approve(cabinAddy, depBal);
            cabin.sheppardGoHome(depBal);
        vm.stopPrank();
        vm.startPrank(WETHWhale);
            IERC20(WETH).approve(cabinAddy, 8 * 1e18);
            cabin.addToWoodPile(4 * 1e18);
            cabin.burnTheCabin();
        vm.stopPrank();
    }

    function testFailBurnDownCabinEarly() public {
        vm.startPrank(dep);      
            uint256 depBal = IERC20(LP).balanceOf(dep);
            IERC20(LP).approve(cabinAddy, depBal);
            cabin.sheppardGoHome(depBal);
        vm.stopPrank();
        vm.startPrank(WETHWhale);
            IERC20(WETH).approve(cabinAddy, 8 * 1e18);
            cabin.addToWoodPile(3 * 1e18);
            cabin.burnTheCabin();
        vm.stopPrank();
    }

    function testSaveTheCabin() public {
        vm.startPrank(dep);      
            uint256 depBal = IERC20(LP).balanceOf(dep);
            IERC20(LP).approve(cabinAddy, depBal);
            cabin.sheppardGoHome(depBal);
            cabin.collectWater();
        vm.stopPrank();
        
        emit log_uint(block.timestamp);
        vm.warp(block.timestamp + 604801);
        emit log_uint(block.timestamp);
        
        vm.startPrank(dep);
            cabin.saveTheCabin();
        vm.stopPrank();

        assert(IERC20(LP).balanceOf(cabinAddy) == 0);
        assert(IERC20(LP).balanceOf(dep) == depBal);
        
    }





}
