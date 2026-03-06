// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";
import "./VaultNFT.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract VaultFactory {

    mapping(address => address) public vaults;

    VaultNFT public nft;

    event VaultCreated(address token, address vault);

    constructor(address _nft) {
        nft = VaultNFT(_nft);
    }

    function createVault(address token) external returns (address) {

        require(vaults[token] == address(0), "Vault exists");

        bytes32 salt = keccak256(abi.encode(token));

        // vault addresses become deterministic with create2, so we can predict them before they are deployed
        Vault vault = new Vault{salt: salt}(token, msg.sender);

        vaults[token] = address(vault);

        // define variables used in metadata
        string memory amountString = "0"; // initial deposit is zero when vault is created
        address vaultAddress = address(vault);

        string memory metadata = string(
            abi.encodePacked(
                "Token: USDC | Deposit: ",
                amountString,
                " | Vault: ",
                toAsciiString(vaultAddress)
            )
        );

        nft.mint(msg.sender, metadata);

        emit VaultCreated(token, address(vault));

        return address(vault);
    }


    function getVault(address token) external view returns (address) {
        return vaults[token];
    }

    function toAsciiString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint160(addr), 20);
    }

}



// function tokenURI(uint256 id) public view override returns (string memory) {

//     string memory data = vaultMetadata[id];

//     string memory svg = string(
//         abi.encodePacked(
//             '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="300" viewBox="0 0 500 300">',

//             // Background
//             '<defs>',
//             '<linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">',
//             '<stop offset="0%" style="stop-color:#141E30;stop-opacity:1" />',
//             '<stop offset="100%" style="stop-color:#243B55;stop-opacity:1" />',
//             '</linearGradient>',
//             '</defs>',

//             '<rect width="100%" height="100%" fill="url(#grad)" rx="15"/>',

//             // Vault Icon
//             '<circle cx="60" cy="60" r="30" fill="#4CAF50"/>',
//             '<rect x="50" y="50" width="20" height="20" fill="white" rx="3"/>',

//             // Title
//             '<text x="120" y="70" fill="white" font-size="26" font-family="sans-serif">',
//             'Vault NFT',
//             '</text>',

//             // Divider
//             '<line x1="40" y1="100" x2="460" y2="100" stroke="#ffffff33" stroke-width="2"/>',

//             // Metadata text
//             '<text x="40" y="140" fill="#E0E0E0" font-size="16" font-family="monospace">',
//             data,
//             '</text>',

//             // Footer
//             '<text x="40" y="260" fill="#aaaaaa" font-size="12" font-family="sans-serif">',
//             'On-chain Vault Position',
//             '</text>',

//             '</svg>'
//         )
//     );

//     return string(
//         abi.encodePacked(
//             "data:image/svg+xml;utf8,",
//             svg
//         )
//     );
// }
