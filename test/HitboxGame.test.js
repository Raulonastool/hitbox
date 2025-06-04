const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxGame", function () {
  let game;

  beforeEach(async function () {
    const HitboxGame = await ethers.getContractFactory("HitboxGame");
    game = await HitboxGame.deploy();
    await game.waitForDeployment();
  });

  it("starts at position (0,0)", async function () {
    const pos = await game.character();
    expect(pos.x).to.equal(0n);
    expect(pos.y).to.equal(0n);
  });

  it("moves the character", async function () {
    await (await game.move(1, 2)).wait();
    const pos = await game.character();
    expect(pos.x).to.equal(1n);
    expect(pos.y).to.equal(2n);
  });

  it("does not move below zero", async function () {
    await (await game.move(1, 2)).wait();
    await (await game.move(-5, -3)).wait();
    const pos = await game.character();
    expect(pos.x).to.equal(0n);
    expect(pos.y).to.equal(0n);
  });

  it("stores revealed tiles", async function () {
    await (await game.reveal(5, 6)).wait();
    const key = ethers.solidityPackedKeccak256(["uint256", "uint256"], [5, 6]);
    expect(await game.revealed(key)).to.equal(true);
  });
});
