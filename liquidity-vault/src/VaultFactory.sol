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

        nft.mint(
            msg.sender,
            string(
                abi.encodePacked(
                    "Vault for token: ",
                    toAsciiString(token)
                )
            )
        );

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