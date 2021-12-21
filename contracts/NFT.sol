// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// we need the openzeppelin ERC721 NFT functionality

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // counters allows us to keep track of tokenIds
    //address of marketplace for NFTs to interact
    address contractAddress;

    // OBJ: give the NFT the ability to transact with tokens or change ownership
    // SetApprovalForAll allows us to do that with contract address

    constructor(address marketPlaceAddress) ERC721("KryptoBirdz", "KBIRDZ") {
        contractAddress = marketPlaceAddress;
    }
}
