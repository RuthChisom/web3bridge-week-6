// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainNFT is ERC721 {
    using Strings for uint;
    uint256 public tokenId;

    constructor() ERC721 ("ceceNFT", "cece") {
        tokenId = 1;
    }

    event NFTMinted(address indexed owner, uint256 tokenId);

    function generateSVG() internal pure returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
            '<rect width="100%" height="100%" fill="black" />',
            '<circle cx="250" cy="250" r="210" fill="orange" />',
            '<circle cx="250" cy="250" r="190" fill="white" />',
            '<circle cx="250" cy="250" r="170" fill="red" />',
            '<circle cx="250" cy="250" r="150" fill="yellow" />',
            '<circle cx="250" cy="250" r="130" fill="green" />',
            '<circle cx="250" cy="250" r="110" fill="blue" />',
            '<circle cx="250" cy="250" r="90" fill="purple" />',
            '<circle cx="250" cy="250" r="70" fill="pink" />',
            '<circle cx="250" cy="250" r="50" fill="brown" />',
            '<circle cx="250" cy="250" r="30" fill="black" />',
            '</svg>'
        ));
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg))));
    }

    function mintNFT() public {
        tokenId++;
        _safeMint(msg.sender, tokenId);
        emit NFTMinted(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenTxId) public view override returns (string memory) {
        ownerOf(tokenTxId);

        string memory name = string(abi.encodePacked("som ", Strings.toString(tokenTxId)));
        string memory description = "My NFT";
        string memory image = generateSVG();

        string memory json = string(
            abi.encodePacked(
                '{"name": "', name, '", ',
                '"description": "', description, '", ',
                '"image": "', image, '"}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }
}