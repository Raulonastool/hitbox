const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxNFT", function () {
  let game, nft, owner;
  const validTile = ethers.utils.toUtf8Bytes("validTile");

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    const Game = await ethers.getContractFactory("HitboxGame");
    game = await Game.deploy();
    await game.deployed();

    const NFT = await ethers.getContractFactory("HitboxNFT");
    nft = await NFT.deploy(game.address, "ipfs://base");
    await nft.deployed();

    await game.authorize(owner.address);
    await nft.mint(owner.address, 1);
  });

  it("returns dynamic tokenURI", async function () {
    await game.move(3, validTile); // move right to (1,0) but will reset
    const uri = await nft.tokenURI(1);
    expect(uri).to.contain("ipfs://base/1");
    expect(uri).to.contain("x=0");
    expect(uri).to.contain("y=0");
  });
});
