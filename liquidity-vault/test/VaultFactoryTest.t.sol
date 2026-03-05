// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/VaultFactory.sol";
import "../src/VaultNFT.sol";

interface IERC20 {
    function transfer(address,uint256) external returns(bool);
    function approve(address,uint256) external returns(bool);
}

contract VaultFactoryTest is Test {

    VaultFactory factory;
    VaultNFT nft;

    address USDC =
        0xA0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;

    address USDC_WHALE =
        0x55fe002aeff02f77364de339a1292923a15844b8;

    function setUp() public {

        // loads Ethereum mainnet locally. We can use any block number, but using a recent one will make sure the USDC whale has funds.
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));

        nft = new VaultNFT();

        factory = new VaultFactory(address(nft));
    }

    function testCreateVault() public {

        address vault = factory.createVault(USDC);

        assertTrue(vault != address(0));
    }

    function testDepositRealUSDC() public {

        address vaultAddr = factory.createVault(USDC);

        Vault vault = Vault(vaultAddr);

        // impersonate the USDC whale, who has a lot of USDC and can approve our vault to spend it
        vm.startPrank(USDC_WHALE);

        IERC20(USDC).approve(vaultAddr, 1000e6);

        vault.deposit(1000e6);

        vm.stopPrank();
    }
}