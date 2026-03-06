// mint an NFT when a vault is created
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract VaultNFT is ERC721 {

    uint256 public tokenId;

    // Metadata will include: token symbol, deposit amount and vault address
    mapping(uint256 => string) public vaultMetadata;

    constructor() ERC721("Vault NFT", "VAULT") {}

    function mint(
        address to,
        string memory metadata
    ) external returns (uint256) {

        tokenId++;

        _mint(to, tokenId);

        vaultMetadata[tokenId] = metadata;

        return tokenId;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {

        string memory data = vaultMetadata[id];

        // build SVG image
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="200">',
                '<rect width="100%" height="100%" fill="black"/>',
                '<text x="20" y="40" fill="white" font-size="20">Vault NFT</text>',
                '<text x="20" y="80" fill="white">', data ,'</text>',
                '</svg>'
            )
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;utf8,",
                svg
            )
        );
    }
}
