// mint an NFT when a vault is created
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";

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
        return vaultMetadata[id];
    }
}