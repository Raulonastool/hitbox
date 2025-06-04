const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HitboxGame", function () {
  let game;
  let owner, user;
  const validTile = ethers.utils.toUtf8Bytes("validTile");

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const Game = await ethers.getContractFactory("HitboxGame");
    game = await Game.deploy();
    await game.deployed();
  });

  it("allows authorized movement and tile reveal", async function () {
    await game.authorize(owner.address);
    await expect(game.move(3, validTile))
      .to.emit(game, "CharacterMoved")
      .withArgs(1, 0);
    const pos = await game.getPosition();
    expect(pos[0]).to.equal(1);
    expect(await game.revealed(1, 0)).to.equal(true);
  });

  it("reverts unauthorized moves", async function () {
    await expect(game.connect(user).move(3, validTile)).to.be.revertedWith(
      "Not authorized"
    );
  });

  it("resets position on collision", async function () {
    await game.authorize(owner.address);
    // First move right into obstacle at (1,0)
    await game.move(3, validTile);
    const pos = await game.getPosition();
    expect(pos[0]).to.equal(0);
    expect(pos[1]).to.equal(0);
  });

  it("reverts on invalid proof", async function () {
    await game.authorize(owner.address);
    const bad = ethers.utils.toUtf8Bytes("badTile");
    await expect(game.move(3, bad)).to.be.revertedWith("Invalid proof");
  });
});
