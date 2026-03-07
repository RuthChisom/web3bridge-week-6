// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";
import "./VaultNFT.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract VaultFactory {

    using Strings for uint256;

    mapping(address => address) public vaults;
    VaultNFT public nft;

    event VaultCreated(address token, address vault);
    event NFTUpdated(uint256 tokenId, string metadata);

    constructor(address _nft) {
        nft = VaultNFT(_nft);
    }

    //use create2 to deploy vaults at deterministic addresses based on token address
    function createVault(address token) external returns (address) {
        require(vaults[token] == address(0), "Vault exists");

        bytes32 salt = keccak256(abi.encode(token));

        Vault vault = new Vault{salt: salt}(token, msg.sender); //deploy vault with token address and creator as parameters

        vaults[token] = address(vault);

        emit VaultCreated(token, address(vault));

        return address(vault);
    }

    /// @notice Called after deposit to mint NFT with actual deposit amount
    function mintVaultNFT(
        address vaultAddress,
        address token,
        uint256 amount
    ) external returns (uint256) {

        require(vaults[token] == vaultAddress, "Vault not found");

        string memory metadata = string(
            abi.encodePacked(
                "Token: USDC | Deposit: ",
                amount.toString(),
                " | Vault: ",
                Strings.toHexString(uint160(vaultAddress), 20)
            )
        );

        uint256 id = nft.mint(msg.sender, metadata);

        emit NFTUpdated(id, metadata);

        return id;
    }

    function getVault(address token) external view returns (address) {
        return vaults[token];
    }

}
