# SheepCoin

🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑🐑

This is a novel MemeCoin project

Its basic premise is that the transfer function is restricted by the token holder count.
🐑 = 1 token can transfer
🐑🐑 = 2 tokens can transfer

This will stop early buyers from buying up huge allocations. and also help to restrict wallets from emptying out all their tokens. 

💻💻💻

`herdSize()`
Keep in mind that you must take note of the token holder number. If you attempt to cause more to be transferred the transaction will fail. 
To see the current token holders you can query the variable `herdSize()` as seen in the image below. 
`takeToPasture()` 
This function will likely only be called once, and it turns on the `transfer()` restrictions. A value of true means transfers are restricted.
`releaseLassie()`
This function will only be called if they experiment is considered a failure and the original LP needs to be dismantled. This has will start the 1 week cool down. 
If this function is called, the bots will notify you, and it might then be a good idea to exit any SHEEP tokens you are holding back to the right side token.
`herded()`
This is a timestamp of when a cool down has been started. This number plus `604800` will be the time when the transfer restrictions can be turned off.
`penTheSheep()`
This function will turn off the transfer restrictions after the cooldown has passed.
`eatSheep()`
This function will burn SHEEP in any address except the LP and the SheepDOG. It can only be called by the WOLF NFTs

🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺🐺

The Wolf NFT has the power to EAT sheep. To get a wolf you need to feed it some SHEEP. The 1st WOLF costs 10 Sheep, then each WOLF there after is 10 more Sheep
* Wolf 1 = 10 SHEEP
* Wolf 2 = 20 SHEEP
* Wolf 3 = 30 SHEEP

Wolf NFTs get hungry and can even starve to death, but they also do get full and grow. 
Wolf NFTS:
* can eat once then they have to wait 24 hours to eat again
* must eat at least once every week, to extend their life another week
* eat more SHEEP each time they eat, 1st time 1 SHEEP, 2nd time 2 SHEEP, 3rd 3 SHEEP...
* can eat any SHEEP anywhere except in the LP and the sheepDOG(see below)

💻💻💻

`getWolf()`
mints you a new WOLF NFT
increases the cost of the next WOLF by 10
starts your hungry, starved timers
`eatSheep()`
allows you to burn sheep tokens in any address except the sheepDOG and the LP
increases your hungry, starved timers accordingly
`setRoyaltyReceiver()`
common address where NFT sale royalties will go


🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶🐑🐶

The sheepDOG is a safe place for sheep. He will protect them from the WOLF NFTs, but he needs to fall asleep before you can take your SHEEP.
I takes the sheepDOG 2 days to fall asleep

💻💻💻

`protect()` 
deposits an amount of SHEEP into the sheepDOG
`dogSleep()`
starts the 2 day timer for you 
`getSheep()`
if your 2 day timer is past, this withdraws your sheep back to you
`starved(WolfID)`
returns blocktime when this wolf will be dead
`hungry(WolfID)`
returns blocktime when this wolf can eat again
`hunger(WolfID)`
returns the cost of minting a new wolf
`mints(address)`
returns the wolfIDs this address has


🔥🛖

The BurnDownTheCabin is for burning the LP tokens if the deployer has be donated some amount. Ideally, the amount of tokens should
equal the amount of right side token that was put in the LP for init liquidity.

This token is not likely to make anyone any money. This is not an investment. This is a game. If you are afraid of loosing, consider just counting the sheep.





