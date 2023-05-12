// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {CABIN} from "src/Cabin.sol";

contract DeployCabin is Script {


    address constant LP = 0x48D26588dd4a236B12c848A85AEDf6613d4b51Ad;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    address constant dep = 0x275946F183925c316feEB920F53562BBfC127134;

    //TODO: Both these should be set BEFORE run()

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CABIN cabin = new CABIN();
        cabin.buildTheCabin(LP, WETH, 4 * 1e18, dep);

        vm.stopBroadcast();
    }
}


