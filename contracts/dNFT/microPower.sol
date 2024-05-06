// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./fetchData.sol";

contract MicroPower is ERC721URIStorage, ConfirmedOwner, fetchData  {

    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public testGen;
    


    mapping(uint256 => uint256) public tokenIdToConsumed;
    mapping(uint256 => uint256) public tokenIdToProvided;

    uint256[] public allTokenIds;

    event NFTMinted(
        address useAddress,
        uint256 tokenId,
        uint256 mintTime
    );


    constructor(uint64 _sucscriptionId) ERC721 ("MicroPower", "MCP") {
        subscriptionId = _sucscriptionId;
    }

    function generateImage(uint256 tokenId) internal view returns(string memory){

    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: black; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="pink" stroke="yellow" stroke-width="5"/>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',"Micro Power NFT",'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Power Consumed: ",getPowerConsumed(tokenId), " KWh",'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Power Provided: ",getPowerProvided(tokenId), " KWh",'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );
}

function getPowerConsumed(uint256 tokenId) public view returns (string memory) {
    uint256 consumed = tokenIdToConsumed[tokenId];
    return consumed.toString();
}
function getPowerProvided(uint256 tokenId) public view returns (string memory) {
    uint256 provided = tokenIdToProvided[tokenId];
    return provided.toString();
}

function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Micro Power NFT #', tokenId.toString(), '",',
            '"description": "Micro Power Consumer NFT",',
            '"image": "', generateImage(tokenId), '",',
            '"powerConsumed": "', getPowerConsumed(tokenId), '",', // Add power consumed attribute
            '"powerProvided": "', getPowerProvided(tokenId), '"' // Add power provided attribute
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
}

function mint() public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    tokenIdToConsumed[newItemId] = 0;
    _setTokenURI(newItemId, getTokenURI(newItemId));

    emit NFTMinted(msg.sender, newItemId, block.timestamp);
}

function updatePowerData(uint256 tokenId) public {
    uint256 consumedValue = getConsumedValue();
    uint256 generatedValue = getGeneratedValue();
    uint256 currentProvidedLevel = tokenIdToProvided[tokenId];
    uint256 currentConsumedLevel = tokenIdToConsumed[tokenId];
    tokenIdToProvided[tokenId] = currentProvidedLevel + generatedValue;
    tokenIdToConsumed[tokenId] = currentConsumedLevel + consumedValue;
    _setTokenURI(tokenId, getTokenURI(tokenId));
}

    // function updatePowerData() public {
    //     for (uint256 i = 0; i < allTokenIds.length; i++) {
    //         uint256 tokenId = allTokenIds[i];
    //         uint256 consumedValue = getConsumedValue(); // Call your external function to get consumed value
    //         uint256 generatedValue = getGeneratedValue(); // Call your external function to get generated value
    //         uint256 currentProvidedLevel = tokenIdToProvided[tokenId];
    //         uint256 currentConsumedLevel = tokenIdToConsumed[tokenId];
    //         tokenIdToProvided[tokenId] = currentProvidedLevel + generatedValue;
    //         tokenIdToConsumed[tokenId] = currentConsumedLevel + consumedValue;
    //         _setTokenURI(tokenId, getTokenURI(tokenId));
    //     }
    // }

}