const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxGame", function () {
  it("initializes worldRoot from constructor", async function () {
    const root = ethers.utils.formatBytes32String("hello");
    const HitboxGame = await ethers.getContractFactory("HitboxGame");
    const game = await HitboxGame.deploy(root);
    await game.deployed();
    expect(await game.worldRoot()).to.equal(root);
  });
});
