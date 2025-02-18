# SheepCoin

🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑

This is a novel GameCoin project

Its basic premise is that sheep left idle will be targets for the hungry wolves.

🐑🐺🍖

The SHEEP coin is the main coin of this project. It is the coin that is fungible and tradable. Most features are
priced in this coin.

💻💻💻

*  `takeOutOfPasture()` 
This function will likely only be called once, and it turns on the `transfer()` restrictions. A value of true means transfers are restricted.
* `mintForFee()`
This function will allow for minting SHEEP for a fee. The purpose of this is to allow for a LGE. During this time token
transfers are restricted.
* `eatSheep()`
This function will burn SHEEP in any address except the SheepDOG. It can only be called by the WOLF NFTs

🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺

The Wolf NFT has the power to EAT sheep. To get a wolf you need to feed it some SHEEP. The 1st WOLF costs 1 Sheep, then each WOLF there after is 1 more Sheep
* Wolf #1 = 1 SHEEP
* Wolf #2 = 2 SHEEP
* Wolf #3 = 3 SHEEP

The Wolf NFT also costs a number of Network Gas Tokens. 95% of these funds goto breeding more SHEEP (see below) 5% to the team..

Wolf NFTs get hungry and can even starve to death, but they also do get full and grow. 
Wolf NFTS:
* can eat once then they have to wait 24 hours to eat again
* must eat at least once every week, to extend their life another week
* eat more SHEEP each time they eat, 1st time 1 SHEEP, 2nd time 2 SHEEP, 3rd 3 SHEEP...Up until a certain Maximum number.
* can eat any SHEEP anywhere except in the Breeder, and the sheepDOG(see below)
* can eat SHEEP from the Liquidity Pool but owners of the wolf will not get the following split.

Sheep that are eaten are split 75 percent burnt and 25 percent to the Wolf NFT owner.

💻💻💻

* `getWolf()`
mints you a new WOLF NFT
increases the cost of the next WOLF by ONE
starts your hungry, starved timers
* `eatSheep()`
allows you to burn sheep tokens in any address except the sheepDOG and the LP
increases your hungry, starved timers accordingly
* `setRoyaltyReceiver()`
common address where NFT sale royalties will go


🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶

The sheepDOG is a safe place for sheep. He will protect them from the WOLF NFTs, but he needs to fall asleep before you can take your SHEEP.
I takes the sheepDOG 2 days to fall asleep. Finally, you will need to pay 10 Network Gas Tokens for each day you are protected by the sheepDog. 95% of these funds goto breeding more SHEEP (see below) 5% to the team.

💻💻💻

* `protect()` 
deposits an amount of SHEEP into the sheepDOG
* `dogSleep()`
starts the 2 day timer for you 
* `getSheep()`
if your 2 day timer is past, this withdraws your sheep back to you
* `starved(WolfID)`
returns blocktime when this wolf will be dead
* `hungry(WolfID)`
returns blocktime when this wolf can eat again
* `hunger(WolfID)`
returns the cost of minting a new wolf
* `mints(address)`
returns the wolfIDs this address has

🐑🐑👶🐑🐑👶🐑🐑👶🐑🐑👶🐑🐑👶🐑🐑👶🐑🐑👶

The breeding is a mechanic where fees are used to purchase SHEEP from the market and are given to people in the sheepDog prorata.


//deprecated features below



💻💻💻
* `buySheep()` 
uses any gasTokens in contract to buy sheep from the market
* `breedSheep()`
deposits two sheep from wallet to this contract and starts the cool down
* `getSheep()`
after cool down, allows user to withdraw 3 sheep


🔥🛖

The BurnDownTheCabin is for burning the LP tokens if the deployer has be donated some amount. Ideally, the amount of tokens should
equal the amount of right side token that was put in the LP for init liquidity.

This token is not likely to make anyone any money. This is not an investment. This is a game. If you are afraid of loosing, consider just counting the sheep.





