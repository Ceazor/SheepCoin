// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LPRescue.sol";

contract TestLPRescue is Test {
    LPRescue public lprescue;

    address constant v1LP = 0xe24960a5B396a6E1eDA5C6EA0D1eb29480404B1d;
    address constant dep = 0x275946F183925c316feEB920F53562BBfC127134;

    uint256 arbFork;

    function setUp() public {
        arbFork = vm.createFork(vm.envString('ARB_RPC_URL'));

        vm.startPrank(dep);
            lprescue = new LPRescue();
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
