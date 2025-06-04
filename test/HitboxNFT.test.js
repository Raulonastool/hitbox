const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxNFT", function () {
  let game, nft, owner, other;

  beforeEach(async function () {
    [owner, other] = await ethers.getSigners();
    const HitboxGame = await ethers.getContractFactory("HitboxGame");
    game = await HitboxGame.deploy();
    await game.waitForDeployment();
    const HitboxNFT = await ethers.getContractFactory("HitboxNFT");
    nft = await HitboxNFT.deploy(await game.getAddress());
    await nft.waitForDeployment();
  });

  it("mints an NFT to the owner", async function () {
    await (await nft.mint(owner.address)).wait();
    expect(await nft.ownerOf(1n)).to.equal(owner.address);
    expect(await nft.nextTokenId()).to.equal(2n);
  });

  it("mints to another address", async function () {
    await (await nft.mint(other.address)).wait();
    expect(await nft.ownerOf(1n)).to.equal(other.address);
  });

  it("allows multiple mints", async function () {
    await (await nft.mint(owner.address)).wait();
    await (await nft.mint(owner.address)).wait();
    expect(await nft.ownerOf(1n)).to.equal(owner.address);
    expect(await nft.ownerOf(2n)).to.equal(owner.address);
    expect(await nft.nextTokenId()).to.equal(3n);
  });
});
