# NFT-Auction
Auction your NFT with a starting bid.

This contract allows you to auction your NFT securely, with a starting bid (in WEI) and an end time.
Once the end time is reached, if no one bidded on your NFT, you can use the end() and withdraw() functions and get your NFT back, as well as your starting bid.

If someone placed the highest bid and the end time is reached, use the end() function to finalize the auction.
