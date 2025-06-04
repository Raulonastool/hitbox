const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxNFT", function () {
  let game, nft, owner, other;

  beforeEach(async function () {
    [owner, other] = await ethers.getSigners();

    // Deploy HitboxGame (root = keccak256("dummyRoot"), start at 0,0)
    const Game = await ethers.getContractFactory("HitboxGame");
    const root = ethers.keccak256(ethers.toUtf8Bytes("dummyRoot"));
    game = await Game.deploy(root, 0, 0);
    await game.waitForDeployment();

    // Deploy HitboxNFT
    const NFT = await ethers.getContractFactory("HitboxNFT");
    nft = await NFT.deploy(await game.getAddress());
    await nft.waitForDeployment();
  });

  it("mints an NFT to the sender", async function () {
    await nft.connect(owner).mint();          // tokenId 0
    expect(await nft.ownerOf(0n)).to.equal(owner.address);
    expect(await nft.nextId()).to.equal(1n);
  });

  it("mints to another account", async function () {
    await nft.connect(other).mint();          // tokenId 0
    expect(await nft.ownerOf(0n)).to.equal(other.address);
  });

  it("allows multiple mints and tracks nextId", async function () {
    await nft.connect(owner).mint();          // tokenId 0
    await nft.connect(owner).mint();          // tokenId 1
    expect(await nft.ownerOf(0n)).to.equal(owner.address);
    expect(await nft.ownerOf(1n)).to.equal(owner.address);
    expect(await nft.nextId()).to.equal(2n);
  });

  it("returns a base64-encoded JSON data URI", async function () {
    await nft.connect(owner).mint();          // tokenId 0
    const uri = await nft.tokenURI(0);
    expect(uri.startsWith("data:application/json;base64,")).to.be.true;
  });
});
