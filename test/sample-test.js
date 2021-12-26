const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KBMarket", function () {
  it("Should mint and trade NFTs", async function () {

    // Test to receive contract address
    const Market = await ethers.getContractFactory("KBMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = await market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    // Test to receive listing and action prices
    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();
    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    // test for minting
    await nft.mintToken('https-t1')
    await nft.mintToken('https-t2')

    await market.mintMarketItem(nftContractAddress, 1, auctionPrice, {value: listingPrice});
    await market.mintMarketItem(nftContractAddress, 2, auctionPrice, {value: listingPrice});

    // test for different addresses from different users - test accounts
    // return an array of different addresses

    const [_, buyerAddress ] = await ethers.getSigners();

    // create a market sale with address, id and price
    await market.connect(buyerAddress).createMarketSales(nftContractAddress, 1, {
      value: auctionPrice
    });

    const items = await market.fetchMarketTokens();

    // test out all the items 
    console.log('items', items);

  });
});
