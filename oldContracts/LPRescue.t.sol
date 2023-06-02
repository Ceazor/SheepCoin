// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LPRescue.sol";

contract TestLPRescue is Test {
    LPRescue public lprescue;

    address constant v1LP = 0xe24960a5B396a6E1eDA5C6EA0D1eb29480404B1d;
    address constant wallet = 0x275946F183925c316feEB920F53562BBfC127134;
    address lpRescueAddy = 0x1ce0c7f6Ed5d0418fCBdCb3a457E67aDAcB6CE18;
    address public sheepV1 = 0xcEF7d1A0b5b42c9B058FcDE9C5BFe814a3bAa4f2;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;


    uint256 arbFork;

    function setUp() public {
        arbFork = vm.createFork(vm.envString('ARB_RPC_URL'));

        vm.startPrank(wallet);
            lprescue = new LPRescue();
        vm.stopPrank();
    }

    // function testReturnLp() public {
    //     vm.startPrank(wallet);
    //         uint256 lpBal = IERC20(v1LP).balanceOf(wallet);
    //         IERC20(v1LP).transfer(lpRescueAddy, lpBal);
    //         assert(IERC20(v1LP).balanceOf(wallet) == 0);
    //         assert(IERC20(v1LP).balanceOf(lpRescueAddy) == lpBal);
    //         lprescue.returnLP();
    //         assert(IERC20(v1LP).balanceOf(wallet) == lpBal);
    //     vm.stopPrank();

    // }

    function testSaveLp() public {
        vm.warp(block.timestamp + 604801);

        vm.startPrank(wallet);
            uint256 lpBal = IERC20(v1LP).balanceOf(wallet);
            IERC20(v1LP).transfer(lpRescueAddy, lpBal);
            ISheep(sheepV1).transferOwnership(lpRescueAddy);
            lprescue.save(); 
            assert(wallet.balance > 7 * 1e18);           
        vm.stopPrank();

    }








    





}
