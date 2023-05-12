// SPDX-License-Identifier: MIT

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/interfaces/ISheep.sol";
import "src/interfaces/ILP.sol";
import "src/interfaces/IRouter.sol";

pragma solidity ^0.8.13;

contract LPRescue is Ownable {
    address public camelotRouter = 0xc873fEcbd354f5A56E00E710B90EF4201db2448d;
    address public lp = 0xe24960a5B396a6E1eDA5C6EA0D1eb29480404B1d;
    address public sheepV1 = 0xcEF7d1A0b5b42c9B058FcDE9C5BFe814a3bAa4f2;
    address public wallet = 0x275946F183925c316feEB920F53562BBfC127134;

    function save() public onlyOwner {
        penTheSheep();
        withdrawLP();
    }

    function penTheSheep() internal {
        ISheep(sheepV1).penTheSheep();
    }
    function withdrawLP() internal {
        uint256 lpBal = ILP(lp).balanceOf(address(this));

        ILP(lp).approve(camelotRouter, lpBal);
        IRouter(camelotRouter).removeLiquidityETH(
            0xcEF7d1A0b5b42c9B058FcDE9C5BFe814a3bAa4f2,
            lpBal,
            249560000000000000000000,
            8500000000000000000,
            wallet,
            1684969540 );
    }

    function returnLP() public onlyOwner {
        uint256 lpBal = ILP(lp).balanceOf(address(this));
        ILP(lp).transfer(wallet, lpBal);
    }

    function returnOwnership() public onlyOwner {
        ISheep(sheepV1).transferOwnership(wallet);
    }

}