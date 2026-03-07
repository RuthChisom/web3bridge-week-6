// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import "../src/VaultFactory.sol";
import "../src/VaultNFT.sol";

contract VaultFactoryTest is Test {

    VaultFactory factory;
    VaultNFT nft;

    address USDC =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address USDC_WHALE =
        0x55FE002aefF02F77364de339a1292923A15844B8;

    function setUp() public {

        // loads Ethereum mainnet locally. We can use any block number, but using a recent one will make sure the USDC whale has funds.
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));

        nft = new VaultNFT();
        factory = new VaultFactory(address(nft));


        console.log("NFT Contract:", address(nft));
        console.log("Factory Contract:", address(factory));
    }

    function testCreateVault() public {

        address vault = factory.createVault(USDC);
        console.log("Vault created at:", vault);

        uint256 id = nft.tokenId();
        console.log("NFT id: ",id);

        string memory uri = nft.tokenURI(id);
        console.log("NFT URI: ",uri);

        assertTrue(vault != address(0));
    }

    function testDepositRealUSDC() public {

        address vaultAddr = factory.createVault(USDC);

        console.log("Vault address:", vaultAddr);

        Vault vault = Vault(vaultAddr);

        // impersonate the USDC whale, who has a lot of USDC and can approve our vault to spend it
        vm.startPrank(USDC_WHALE);

        console.log("Whale address:", USDC_WHALE);

        uint256 whaleBalance = IERC20(USDC).balanceOf(USDC_WHALE);
        console.log("Whale USDC Balance:", whaleBalance);

        IERC20(USDC).approve(vaultAddr, 1000e6);

        console.log("Approved 1000 USDC to vault");

        vault.deposit(1000e6);

        console.log("Deposited 1000 USDC");

        uint256 vaultBalance = IERC20(USDC).balanceOf(vaultAddr);
        console.log("Vault USDC Balance:", vaultBalance);

        vm.stopPrank();

        // Now mint the NFT reflecting the deposit
        uint256 nftId = factory.mintVaultNFT(vaultAddr, USDC, 1000);

        string memory uri = nft.tokenURI(nftId);

        console.log("Vault address:", vaultAddr);
        console.log("NFT URI:", uri);
    }
}