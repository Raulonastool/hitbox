const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxGame", function () {
  let game;

  // Deploy a fresh game before each test
  beforeEach(async function () {
    const root = ethers.keccak256(ethers.toUtf8Bytes("dummyRoot"));
    const Game = await ethers.getContractFactory("HitboxGame");
    game = await Game.deploy(root, 0, 0);   // start at (0,0)
    await game.waitForDeployment();
  });

  it("starts at position (0,0)", async function () {
    const pos = await game.characterPosition(); // tuple [x, y]
    expect(pos[0]).to.equal(0n);
    expect(pos[1]).to.equal(0n);
  });

  it("moves the character right by 1", async function () {
    await (await game.move(1, 0)).wait();  // dx = +1, dy = 0  ⇒ Right
    const pos = await game.characterPosition();
    expect(pos[0]).to.equal(1n);
    expect(pos[1]).to.equal(0n);
  });

  it("does not move below zero", async function () {
    // Attempt to move left while already at x = 0
    await (await game.move(-1, 0)).wait();
    const pos = await game.characterPosition();
    expect(pos[0]).to.equal(0n);
    expect(pos[1]).to.equal(0n);
  });

  it("stores revealed tiles", async function () {
    await (await game.reveal(5, 6)).wait();
    const key = ethers.solidityPackedKeccak256(["uint256", "uint256"], [5, 6]);
    expect(await game.revealedTiles(key)).to.equal(true);
  });
});
