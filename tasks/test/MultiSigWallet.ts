import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ethers } from "hardhat";

describe("MultiSigWallet", function () {
  let wallet: any;
  let owners: string[]; 
  let user1: any;
  let user2: any;
  let user3: any;
  let nonOwner: any;
  let recipient: any;
  let provider: any;

  beforeEach(async function () {
    [user1, user2, user3, nonOwner, recipient] =
      await hre.ethers.getSigners();
      owners = [user1.address, user2.address, user3.address];

    const Wallet = await hre.ethers.getContractFactory("MultiSigWallet");
    wallet = await Wallet.deploy(owners, 3); // 3 signatures required
    await wallet.deployed();

    provider = hre.ethers.provider;
  });

  it("should accept deposits", async function () {
    await user1.sendTransaction({
      to: wallet.address,
      value: ethers.utils.parseEther("2"),
    });

    const balance = await provider.getBalance(wallet.address);
    expect(balance).to.equal(ethers.utils.parseEther("2"));
  });

  it("should allow owners to create transactions", async function () {
    await wallet.connect(user1).createTransaction(recipient.address, ethers.utils.parseEther("1"));
    const tx = await wallet.getTransactions();
    expect(tx.length).to.equal(1);
    expect(tx[0].to).to.equal(recipient.address);
  });

  it("should not allow non-owners to create transactions", async function () {
    await expect(
      wallet.connect(nonOwner).createTransaction(recipient.address, ethers.utils.parseEther("1"))
    ).to.be.revertedWith("Not an owner");
  });

  it("should allow owners to sign and execute transactions", async function () {
    // Deposit funds
    await user1.sendTransaction({
      to: wallet.address,
      value: ethers.utils.parseEther("3"),
    });

    // Create transaction
    await wallet.connect(user1).createTransaction(recipient.address, ethers.utils.parseEther("2"));

    // Sign with all three owners
    await wallet.connect(user1).signTransaction(0);
    await wallet.connect(user2).signTransaction(0);
    await wallet.connect(user3).signTransaction(0);

    // Execute transaction
    await wallet.connect(user1).executeTransaction(0);

    const balance = await provider.getBalance(wallet.address);
    expect(balance).to.equal(ethers.utils.parseEther("1")); // 3 - 2
  });

  it("should not execute transaction without enough signatures", async function () {
    await user1.sendTransaction({
      to: wallet.address,
      value: ethers.utils.parseEther("2"),
    });

    await wallet.connect(user1).createTransaction(recipient.address, ethers.utils.parseEther("2"));
    await wallet.connect(user1).signTransaction(0);
    await wallet.connect(user2).signTransaction(0);

    await expect(wallet.connect(user1).executeTransaction(0)).to.be.revertedWith("Not enough signatures");
  });

  it("should prevent double signing by the same owner", async function () {
    await wallet.connect(user1).createTransaction(recipient.address, ethers.utils.parseEther("1"));
    await wallet.connect(user1).signTransaction(0);

    await expect(wallet.connect(user1).signTransaction(0)).to.be.revertedWith("Already signed");
  });

  it("should prevent executing an already executed transaction", async function () {
    await user1.sendTransaction({
      to: wallet.address,
      value: ethers.utils.parseEther("2"),
    });

    await wallet.connect(user1).createTransaction(recipient.address, ethers.utils.parseEther("2"));
    await wallet.connect(user1).signTransaction(0);
    await wallet.connect(user2).signTransaction(0);
    await wallet.connect(user3).signTransaction(0);

    await wallet.connect(user1).executeTransaction(0);

    await expect(wallet.connect(user1).executeTransaction(0)).to.be.revertedWith("Transaction already executed");
  });
});
