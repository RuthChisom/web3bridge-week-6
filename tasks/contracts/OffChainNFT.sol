// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HiddenLeaf is ERC721URIStorage, Ownable {

    constructor() ERC721("Leaf Village", "LV") Ownable(msg.sender) {}
    

    //Function to mint a new artwork
    function mintArtwork(address _to, uint256 _tokenId, string memory _tokenURI) public onlyOwner {
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }
}