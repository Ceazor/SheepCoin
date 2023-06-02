// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {LPRescue} from "src/LPRescue.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";
import "src/interfaces/ISheep.sol";




contract DeployRescue is Script {

    address public sheepV1 = 0xcEF7d1A0b5b42c9B058FcDE9C5BFe814a3bAa4f2;
    address public lp = 0xe24960a5B396a6E1eDA5C6EA0D1eb29480404B1d;
    address constant wallet = 0x275946F183925c316feEB920F53562BBfC127134;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;


    //TODO: Both these should be set BEFORE run()

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        LPRescue rescue = new LPRescue();


        // uint256 lpBal = IERC20(lp).balanceOf(wallet);    

        // address rescueAddy = 0x1ce0c7f6Ed5d0418fCBdCb3a457E67aDAcB6CE18;
        // IERC20(lp).transfer(rescueAddy, lpBal);
        // ISheep(sheepV1).transferOwnership(rescueAddy);

        // uint256 wethBalb4 = wallet.balance;
        // console2.log("wethBal", wethBalb4);

        // rescue.save();  

        // uint256 wethBal = wallet.balance;
        // console2.log("wethBal", wethBal);

        vm.stopBroadcast();
    }
}


