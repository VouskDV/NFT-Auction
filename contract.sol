pragma solidity ^0.8.10;

/** 
 NFT Auction Contract

 Twitter: 0xVousk

 /!\ Don't forget to approve the use of your NFT for this contract 

**/


interface IERC721 {
    function transfer(address, uint) external;

    function transferFrom(
        address,
        address,
        uint
    ) external ;
}

contract Auction {
    event Start();
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);

    address payable public seller;

    bool public started;
    bool public ended;
    uint public endAt;
    uint public amountOfDays;

    IERC721 public nft;
    uint public nftId;

    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    constructor (uint _amountOfDays) {
        seller = payable(msg.sender);
        amountOfDays = _amountOfDays * 1 days;
    }

    function start(IERC721 _nft, uint _nftId, uint startingBid) external {
        require(!started, "Auction already started.");
        require(msg.sender == seller, "Auction is not started");
        highestBid = startingBid;

        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);

        started = true;
        endAt = block.timestamp + amountOfDays;

        emit Start();
    }

    function bid() external payable {
        require(started, "Auction is not started.");
        require(block.timestamp < endAt, "Auction ended.");
        require(msg.value > highestBid, "Your bid is lower than the highest actual bid.");

        highestBidder = msg.sender;
        highestBid = msg.value;
        if (highestBidder != address(0)) { /** If the highest bidder isn't the address 0x000.., increment the highest bid **/
            bids[highestBidder] += highestBid;
        }
        emit Bid(highestBidder, highestBid);
    }

    function withdraw() external payable {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}("");
        require(sent, "Could not interact.");

        emit Withdraw(msg.sender, bal);
    }

    /** 
    
    Ends the auction and send the NFT to the highest bidder.
    
    **/

    function end() external {
        require(started, "Auction is not started.");
        require(block.timestamp >= endAt, "Auction is still ongoing");
        require(!ended, "Auction already ended.");

        if (highestBidder != address(0)) { /** If no one placed a bid, the seller get his NFT back. **/
            nft.transfer(highestBidder, nftId);
            (bool sent, bytes memory data) = seller.call{value: highestBid}("");
            require(sent, "Could not interact.");          
        } else {
            nft.transfer(seller, nftId);
        }
        
        ended = true;
        emit End(highestBidder, highestBid);
    }

}
