// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// we need the openzeppelin ERC721 NFT functionality

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Security against transactions for multple transfers

import "hardhat/console.sol";

contract KBMarket is ReentrancyGuard {
    using Counters for Counters.Counter;

    // number of items minting, number of trnsactions, number of items sold and not sold
    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;

    // determine who is th owner of the token
    // charge a listing fee to the seller

    address payable owner;
    // we are deploying to matic the API is the same since they both have the same 18 decimal places. 
    uint256 listingPrice = 0.045 ether;

    constructor(){
        // set the owner 
        owner = payable(msg.sender);
    }

    // struct can act like objects

    struct MarketToken {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // token return which marketToken  - fetch which one

    mapping(uint256 => MarketToken) private idToMarketToken;

    // list to events from the frontend apps
    event MarketTokenMinted(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // get the listing function

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // two functions to get the number of items minted and sold

    function mintMarketItem(address nftContract, uint tokenId, uint price)

    public payable nonReentrant{
        // nonreentraNT IS A MODIFIED to prevent rentry attack
        require(price > 0, "Price must be greater than one wei");
        require(msg.value >= listingPrice, "Price must be greater than the listing price");

        _tokenIds.increment();
        uint itemId = _tokenIds.current();

        // putting it up for sale - bool - no owner
        idToMarketToken[itemId] = MarketToken(itemId, nftContract, tokenId, payable(msg.sender), payable(address(0)), price, false);
    }

    // transfer the token to the seller
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    // IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketTokenMinted(itemId, nftContract, tokenId, msg.sender, address(0), price, false);

    // function to conduct sales 
    functiom createMarketSales(address nftContract, uint tokenId, uint itemId)
    public payable nonReentrant {
        uint price = idToMarketToken[itemId].price;
        uint tokenId = idToMarketToken[itemId].tokenId;
        require(msg.value == price, "Price submit the asking price in order to complete the sale");

        // transfer the amount to the seller
        idToMarketToken[itemId].seller.transfer(msg.value);
        // transfer the token from contract address to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketToken[itemId].owner = payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        _tokensSold.increment();

        payable(owner).transfer(listingPrice);
    }

    // function to fetcth market items - minting, buying, selling
    function fetchMarketTokens() public view returns (MarketToken[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _tokensSold.current();
        uint currentIndex = 0;

        // looping over the number of items created (if number has not been sold, populate the array)

        MarketToken[] memory items = new MarketToken[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    // return nfts that the user has purchased

    function fetchMyNFTs() public view returns (MarketToken[] memory){
        uint totalItemCount = _tokenIds.current();
        // second counter for each invidual user
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        // second loop to loop through he amount you have purchahed with itemcount 
        // check if th ornwe is equal to message.sender

        MarketToken[] memory items = new MarketToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                uint currentId = idToMarketToken[i + 1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
 


}